import 'package:flutter/material.dart';

import '../utils/date_format.dart';

/// Estado actual del equipaje, calculado desde su ultimo evento.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ChipShape(
      background: colorScheme.surfaceContainerHighest,
      foreground: colorScheme.onSurface,
      icon: Icons.circle,
      iconSize: 8,
      label: label,
    );
  }
}

/// Variante D: indicador "Demorado" con el tiempo sin actualizacion.
class DelayedChip extends StatelessWidget {
  const DelayedChip({super.key, required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ChipShape(
      background: colorScheme.error,
      foreground: colorScheme.onError,
      icon: Icons.schedule,
      iconSize: 14,
      label: 'Demorado · ${formatElapsed(elapsed)} sin actualizar',
    );
  }
}

class _ChipShape extends StatelessWidget {
  const _ChipShape({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.iconSize,
    required this.label,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final double iconSize;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
