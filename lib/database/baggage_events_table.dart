import 'package:drift/drift.dart';

/// Cache local de `baggage_events`.
///
/// La clave primaria es el id del evento, no el del equipaje: asi cada
/// equipaje conserva todos sus eventos sin que uno reemplace al anterior.
@DataClassName('BaggageEventRow')
@TableIndex(name: 'idx_baggage_events_baggage_id', columns: {#baggageId})
class BaggageEvents extends Table {
  TextColumn get id => text()();
  TextColumn get baggageId => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
