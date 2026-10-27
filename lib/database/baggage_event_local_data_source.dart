import 'package:drift/drift.dart';

import '../models/baggage_event.dart';
import 'app_database.dart';

/// Operaciones de Drift sobre los eventos. Fuera de esta clase nadie
/// conoce `BaggageEventRow` ni las consultas SQL.
class BaggageEventLocalDataSource {
  BaggageEventLocalDataSource(this.db);

  final AppDatabase db;

  BaggageEvent _toDomain(BaggageEventRow row) {
    return BaggageEvent(
      id: row.id,
      baggageId: row.baggageId,
      type: row.type,
      createdAt: row.createdAt,
    );
  }

  BaggageEventsCompanion _toCompanion(BaggageEvent event) {
    return BaggageEventsCompanion.insert(
      id: event.id,
      baggageId: event.baggageId,
      type: event.type,
      createdAt: event.createdAt,
    );
  }

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    final rows = await (db.select(db.baggageEvents)
          ..where((t) => t.baggageId.equals(baggageId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<List<BaggageEvent>> getAllEvents() async {
    final rows = await (db.select(db.baggageEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    return rows.map(_toDomain).toList();
  }

  /// Upsert por id de evento: inserta si no existe y actualiza si ya estaba.
  Future<void> saveEvent(BaggageEvent event) async {
    await db.into(db.baggageEvents).insertOnConflictUpdate(_toCompanion(event));
  }

  /// Guarda en una sola transaccion los eventos recibidos de Firestore.
  Future<void> saveEvents(List<BaggageEvent> events) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.baggageEvents,
        events.map(_toCompanion).toList(),
      );
    });
  }
}
