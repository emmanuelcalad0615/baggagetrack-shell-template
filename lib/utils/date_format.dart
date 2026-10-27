String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// Formato `dd/MM/yyyy HH:mm` sin depender de `intl`.
String formatDateTime(DateTime date) {
  final local = date.toLocal();
  return '${_twoDigits(local.day)}/${_twoDigits(local.month)}/${local.year} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}

/// Duracion aproximada y legible, por ejemplo `45 min` o `2 h 5 min`.
String formatElapsed(Duration elapsed) {
  final minutes = elapsed.inMinutes;
  if (minutes < 1) return 'menos de 1 min';
  if (minutes < 60) return '$minutes min';

  final hours = elapsed.inHours;
  if (hours < 24) {
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }
  return '${elapsed.inDays} d';
}
