import 'package:baggage_track_shell/models/baggage_event.dart';
import 'package:baggage_track_shell/models/baggage_event_type.dart';
import 'package:baggage_track_shell/models/baggage_tracking.dart';
import 'package:flutter_test/flutter_test.dart';

final _start = DateTime(2026, 10, 26, 8);

BaggageEvent _event(BaggageEventType type, int minute) => BaggageEvent(
      id: 'BG-1001-$minute',
      baggageId: 'BG-1001',
      type: type.code,
      createdAt: _start.add(Duration(minutes: minute)),
    );

void main() {
  group('estado actual', () {
    test('sin eventos', () {
      final tracking = BaggageTracking(const []);

      expect(tracking.statusLabel, 'Sin eventos');
      expect(tracking.nextType, BaggageEventType.checkedIn);
    });

    test('usa el evento mas reciente aunque lleguen desordenados', () {
      final tracking = BaggageTracking([
        _event(BaggageEventType.security, 10),
        _event(BaggageEventType.loaded, 20),
        _event(BaggageEventType.checkedIn, 0),
      ]);

      expect(tracking.currentType, BaggageEventType.loaded);
      expect(tracking.history.map((e) => e.type), [
        'CHECKED_IN',
        'SECURITY',
        'LOADED',
      ]);
      expect(tracking.nextType, BaggageEventType.inTransit);
    });
  });

  group('transiciones', () {
    final tracking = BaggageTracking([
      _event(BaggageEventType.checkedIn, 0),
      _event(BaggageEventType.security, 10),
    ]);

    test('acepta el siguiente estado', () {
      expect(tracking.validateNext('LOADED'), isNull);
    });

    test('rechaza saltar, repetir o retroceder', () {
      expect(tracking.validateNext('IN_TRANSIT'), isNotNull);
      expect(tracking.validateNext('SECURITY'), isNotNull);
      expect(tracking.validateNext('CHECKED_IN'), isNotNull);
      expect(tracking.validateNext('PERDIDO'), isNotNull);
    });

    test('el primer evento debe ser CHECKED_IN', () {
      expect(BaggageTracking(const []).validateNext('SECURITY'), isNotNull);
      expect(BaggageTracking(const []).validateNext('CHECKED_IN'), isNull);
    });

    test('despues de DELIVERED no hay siguiente evento', () {
      final delivered = BaggageTracking([
        for (final type in BaggageEventType.values)
          _event(type, type.index * 10),
      ]);

      expect(delivered.nextType, isNull);
      expect(delivered.validateNext('CHECKED_IN'), isNotNull);
    });
  });

  group('variante D: demorado', () {
    final loaded = BaggageTracking([
      _event(BaggageEventType.checkedIn, 0),
      _event(BaggageEventType.security, 10),
      _event(BaggageEventType.loaded, 20),
    ]);
    final lastUpdate = _start.add(const Duration(minutes: 20));

    test('mas de 30 minutos sin actualizacion', () {
      expect(loaded.isDelayed(lastUpdate.add(const Duration(minutes: 31))),
          isTrue);
    });

    test('30 minutos exactos o menos no es demora', () {
      expect(loaded.isDelayed(lastUpdate.add(const Duration(minutes: 30))),
          isFalse);
      expect(loaded.isDelayed(lastUpdate.add(const Duration(minutes: 5))),
          isFalse);
    });

    test('sin eventos o entregado nunca es demorado', () {
      final later = _start.add(const Duration(days: 1));
      final delivered = BaggageTracking([
        for (final type in BaggageEventType.values)
          _event(type, type.index * 10),
      ]);

      expect(BaggageTracking(const []).isDelayed(later), isFalse);
      expect(delivered.isDelayed(later), isFalse);
    });
  });
}
