import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'database/baggage_event_local_data_source.dart';
import 'firebase_options.dart';
import 'pages/baggage_list_page.dart';
import 'repositories/baggage_event_repository.dart';
import 'services/baggage_event_remote_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  BaggageEventRemoteService? remote;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    remote = BaggageEventRemoteService(FirebaseFirestore.instance);
  } catch (e) {
    // Sin Firebase la app sigue mostrando la cache de Drift.
    debugPrint('Firebase no disponible: $e');
  }

  final database = AppDatabase();
  final repository = BaggageEventRepository(
    local: BaggageEventLocalDataSource(database),
    remote: remote,
  );

  runApp(BaggageTrackApp(repository: repository));
}

class BaggageTrackApp extends StatelessWidget {
  const BaggageTrackApp({super.key, required this.repository});

  final BaggageEventRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaggageTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BaggageListPage(repository: repository),
    );
  }
}
