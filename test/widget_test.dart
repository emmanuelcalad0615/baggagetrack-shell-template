import 'package:baggage_track_shell/database/app_database.dart';
import 'package:baggage_track_shell/database/baggage_event_local_data_source.dart';
import 'package:baggage_track_shell/main.dart';
import 'package:baggage_track_shell/repositories/baggage_event_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el catalogo inicial', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = BaggageEventRepository(
      local: BaggageEventLocalDataSource(database),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(BaggageTrackApp(repository: repository));
      // Deja terminar la consulta a Drift antes de redibujar.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.text('BaggageTrack'), findsOneWidget);
    expect(find.text('BG-1001'), findsOneWidget);
    expect(find.text('Sin eventos'), findsWidgets);
  });
}
