class BaggageEvent {
  const BaggageEvent({
    required this.id,
    required this.baggageId,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String baggageId;
  final String type;
  final DateTime createdAt;
}
