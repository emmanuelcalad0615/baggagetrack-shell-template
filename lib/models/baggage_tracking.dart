import 'baggage_event.dart';
import 'baggage_event_type.dart';

/// Estado de un equipaje calculado a partir de su historial de eventos.
///
/// Nada de lo que expone esta clase se persiste: el estado actual, el
/// siguiente evento valido y el indicador de demora salen siempre de los
/// eventos del equipaje.
class BaggageTracking {
  BaggageTracking(Iterable<BaggageEvent> events)
      : history = List.unmodifiable(
          events.toList()
            ..sort((a, b) {
              final byDate = a.createdAt.compareTo(b.createdAt);
              return byDate != 0 ? byDate : a.id.compareTo(b.id);
            }),
        );

  /// Variante D: tiempo sin actualizacion a partir del cual un equipaje
  /// que no ha sido entregado se considera demorado.
  static const delayThreshold = Duration(minutes: 30);

  static const noEventsLabel = 'Sin eventos';

  /// Eventos del equipaje, del mas antiguo al mas reciente.
  final List<BaggageEvent> history;

  BaggageEvent? get lastEvent => history.isEmpty ? null : history.last;

  BaggageEventType? get currentType {
    final last = lastEvent;
    return last == null ? null : BaggageEventType.fromCode(last.type);
  }

  String get statusLabel {
    final last = lastEvent;
    if (last == null) return noEventsLabel;
    return currentType?.label ?? last.type;
  }

  bool get isDelivered => currentType == BaggageEventType.delivered;

  /// Siguiente evento permitido. Sin eventos solo se permite CHECKED_IN;
  /// despues de DELIVERED, o con un tipo desconocido, no se permite ninguno.
  BaggageEventType? get nextType {
    if (history.isEmpty) return BaggageEventType.values.first;
    return currentType?.next;
  }

  /// Devuelve el motivo del rechazo, o `null` si [type] es el siguiente
  /// evento valido. El flujo base no permite saltar ni repetir estados.
  String? validateNext(String type) {
    final requested = BaggageEventType.fromCode(type);
    if (requested == null) return 'Tipo de evento desconocido: $type.';

    final expected = nextType;
    if (expected == null) {
      return 'El recorrido del equipaje ya finalizo.';
    }
    if (requested != expected) {
      return 'Transicion no permitida: despues de "$statusLabel" '
          'solo se puede registrar "${expected.label}".';
    }
    return null;
  }

  /// Tiempo transcurrido desde el ultimo evento.
  Duration? timeSinceLastUpdate(DateTime now) {
    final last = lastEvent;
    return last == null ? null : now.difference(last.createdAt);
  }

  /// Variante D: tiene al menos un evento, no esta entregado y su ultima
  /// actualizacion fue hace mas de 30 minutos.
  bool isDelayed(DateTime now) {
    final elapsed = timeSinceLastUpdate(now);
    return elapsed != null && !isDelivered && elapsed > delayThreshold;
  }
}
