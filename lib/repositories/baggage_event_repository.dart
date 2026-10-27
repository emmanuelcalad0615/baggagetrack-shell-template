import 'package:flutter/foundation.dart';

import '../database/baggage_event_local_data_source.dart';
import '../models/baggage_event.dart';
import '../models/baggage_tracking.dart';
import '../services/baggage_event_remote_service.dart';

/// Eventos cargados y el origen del que salieron.
class BaggageEventsResult {
  const BaggageEventsResult({required this.events, required this.fromCache});

  final List<BaggageEvent> events;

  /// `true` cuando Firestore fallo y los eventos vienen de Drift.
  final bool fromCache;
}

/// Error que la UI muestra cuando un evento no se pudo registrar.
class RegisterEventException implements Exception {
  const RegisterEventException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Coordina Firestore (fuente principal) y Drift (cache local).
class BaggageEventRepository {
  BaggageEventRepository({required this.local, this.remote});

  final BaggageEventLocalDataSource local;

  /// `null` cuando Firebase no se pudo inicializar.
  final BaggageEventRemoteService? remote;

  /// Lee primero Firestore y actualiza la cache. Si falla, usa Drift.
  Future<BaggageEventsResult> _load(
    Future<List<BaggageEvent>> Function(BaggageEventRemoteService remote)
        readRemote,
    Future<List<BaggageEvent>> Function() readLocal,
  ) async {
    final remoteSource = remote;
    if (remoteSource != null) {
      try {
        final events = await readRemote(remoteSource);
        await local.saveEvents(events);
        return BaggageEventsResult(events: events, fromCache: false);
      } catch (e) {
        debugPrint('Lectura remota fallida, se usa Drift: $e');
      }
    }

    return BaggageEventsResult(events: await readLocal(), fromCache: true);
  }

  Future<BaggageEventsResult> getAllEvents() => _load(
        (remote) => remote.getEvents(),
        local.getAllEvents,
      );

  Future<BaggageEventsResult> getEventsForBaggage(String baggageId) => _load(
        (remote) => remote.getEventsForBaggage(baggageId),
        () => local.getEventsForBaggage(baggageId),
      );

  /// Valida la transicion con el historial actual del equipaje, guarda en
  /// Firestore y, solo si Firestore confirma, guarda tambien en Drift.
  Future<void> registerEvent(BaggageEvent event) async {
    final current = await getEventsForBaggage(event.baggageId);
    final rejection = BaggageTracking(current.events).validateNext(event.type);
    if (rejection != null) throw RegisterEventException(rejection);

    final remoteSource = remote;
    if (remoteSource == null) {
      throw const RegisterEventException(
        'Firebase no esta disponible. El evento no se registro.',
      );
    }

    try {
      await remoteSource.saveEvent(event);
    } catch (e) {
      debugPrint('Escritura remota fallida: $e');
      throw const RegisterEventException(
        'No se pudo guardar en Firestore. El evento no se registro; '
        'revisa la conexion e intentalo de nuevo.',
      );
    }

    await local.saveEvent(event);
  }
}
