import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'baggage_events_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [BaggageEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Permite abrir la base en memoria desde las pruebas.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'baggage_track.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
