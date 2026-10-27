import 'package:flutter/material.dart';

/// Aviso que se muestra cuando Firestore fallo y los datos vienen de Drift.
class CachedDataBanner extends StatelessWidget {
  const CachedDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sin conexion con Firestore. Se muestran los ultimos datos '
              'guardados en este dispositivo.',
              style: TextStyle(color: colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
