/// Tipos de evento del flujo base, en el orden en que deben registrarse.
enum BaggageEventType {
  checkedIn('CHECKED_IN', 'Registrado en aeropuerto'),
  security('SECURITY', 'Inspeccion de seguridad'),
  loaded('LOADED', 'Cargado en aeronave'),
  inTransit('IN_TRANSIT', 'En transito'),
  delivered('DELIVERED', 'Entregado');

  const BaggageEventType(this.code, this.label);

  /// Valor que se guarda en Firestore y en Drift.
  final String code;
  final String label;

  static BaggageEventType? fromCode(String code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }

  /// Siguiente evento valido, o `null` si este es el ultimo de la secuencia.
  BaggageEventType? get next =>
      index + 1 < values.length ? values[index + 1] : null;
}
