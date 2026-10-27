import 'package:flutter/material.dart';

import '../models/baggage.dart';
import 'status_chip.dart';

class BaggageCard extends StatelessWidget {
  const BaggageCard({
    super.key,
    required this.baggage,
    required this.statusLabel,
    required this.onTap,
    this.delayedFor,
  });

  final Baggage baggage;
  final String statusLabel;
  final VoidCallback onTap;

  /// Tiempo sin actualizacion cuando el equipaje esta demorado; `null` si no.
  final Duration? delayedFor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final delayed = delayedFor;
    final isDelayed = delayed != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: isDelayed ? colorScheme.errorContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDelayed
            ? BorderSide(color: colorScheme.error, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    isDelayed ? colorScheme.error : colorScheme.primaryContainer,
                child: Icon(
                  isDelayed ? Icons.running_with_errors : Icons.luggage_outlined,
                  color: isDelayed
                      ? colorScheme.onError
                      : colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baggage.id,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(baggage.passenger),
                    const SizedBox(height: 3),
                    Text(
                      '${baggage.flight}  ·  ${baggage.destination}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StatusChip(label: statusLabel),
                        if (delayed != null) DelayedChip(elapsed: delayed),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
