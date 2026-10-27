import 'package:baggage_track_shell/database/app_database.dart';
import 'package:baggage_track_shell/database/baggage_event_local_data_source.dart';
import 'package:baggage_track_shell/models/baggage_event.dart';
import 'package:baggage_track_shell/repositories/baggage_event_repository.dart';
import 'package:baggage_track_shell/services/baggage_event_remote_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firestore simulado en memoria. `failing = true` simula la falta de red.
class _FakeRemote implements BaggageEventRemoteService {
  final events = <String, BaggageEvent>{};
  bool failing = false;

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  void _check() {
    if (failing) throw Exception('Firestore no disponible');
  }

  @override
  Future<List<BaggageEvent>> getEvents() async {
    _check();
    return events.values.toList();
  }

  @override
  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    _check();
    return events.values.where((e) => e.baggageId == baggageId).toList();
  }

  @override
  Future<void> saveEvent(BaggageEvent event) async {
    _check();
    events[event.id] = event;
  }
}

BaggageEvent _event(String baggageId, String type, int minute) => BaggageEvent(
      id: '$baggageId-$minute',
      baggageId: baggageId,
      type: type,
      createdAt: DateTime(2026, 10, 26, 8, minute),
    );

void main() {
  late AppDatabase database;
  late BaggageEventLocalDataSource local;
  late _FakeRemote remote;
  late BaggageEventRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    local = BaggageEventLocalDataSource(database);
    remote = _FakeRemote();
    repository = BaggageEventRepository(local: local, remote: remote);
  });

  tearDown(() => database.close());

  test('Drift conserva varios eventos por equipaje y filtra por baggageId',
      () async {
    await local.saveEvent(_event('BG-1001', 'CHECKED_IN', 0));
    await local.saveEvent(_event('BG-1001', 'SECURITY', 5));
    await local.saveEvent(_event('BG-1002', 'CHECKED_IN', 1));
    // Upsert: guardar otra vez el mismo id no duplica la fila.
    await local.saveEvent(_event('BG-1001', 'SECURITY', 5));

    final events = await local.getEventsForBaggage('BG-1001');
    expect(events.map((e) => e.type), ['CHECKED_IN', 'SECURITY']);
    expect(await local.getAllEvents(), hasLength(3));
  });

  test('lectura remota correcta actualiza la cache local', () async {
    remote.events['BG-1001-0'] = _event('BG-1001', 'CHECKED_IN', 0);

    final result = await repository.getEventsForBaggage('BG-1001');

    expect(result.fromCache, isFalse);
    expect(result.events, hasLength(1));
    expect(await local.getEventsForBaggage('BG-1001'), hasLength(1));
  });

  test('si Firestore falla se usan los eventos de Drift', () async {
    remote.events['BG-1001-0'] = _event('BG-1001', 'CHECKED_IN', 0);
    await repository.getAllEvents();
    remote.failing = true;

    final result = await repository.getEventsForBaggage('BG-1001');

    expect(result.fromCache, isTrue);
    expect(result.events.single.type, 'CHECKED_IN');
  });

  test('un evento valido se guarda en Firestore y en Drift', () async {
    await repository.registerEvent(_event('BG-1003', 'CHECKED_IN', 0));

    expect(remote.events, hasLength(1));
    expect(await local.getEventsForBaggage('BG-1003'), hasLength(1));
  });

  test('una transicion invalida se rechaza antes de persistir', () async {
    await expectLater(
      repository.registerEvent(_event('BG-1003', 'LOADED', 0)),
      throwsA(isA<RegisterEventException>()),
    );

    expect(remote.events, isEmpty);
    expect(await local.getAllEvents(), isEmpty);
  });

  test('si la escritura remota falla el evento no queda confirmado', () async {
    remote.failing = true;

    await expectLater(
      repository.registerEvent(_event('BG-1003', 'CHECKED_IN', 0)),
      throwsA(isA<RegisterEventException>()),
    );

    expect(await local.getAllEvents(), isEmpty);
  });
}
