import 'dart:async';

import 'package:flutter/material.dart';

import '../models/baggage.dart';
import '../models/baggage_event.dart';
import '../models/baggage_event_type.dart';
import '../models/baggage_tracking.dart';
import '../repositories/baggage_event_repository.dart';
import '../utils/date_format.dart';
import '../widgets/cached_data_banner.dart';
import '../widgets/status_chip.dart';

class BaggageDetailPage extends StatefulWidget {
  const BaggageDetailPage({
    super.key,
    required this.baggage,
    required this.repository,
  });

  final Baggage baggage;
  final BaggageEventRepository repository;

  @override
  State<BaggageDetailPage> createState() => _BaggageDetailPageState();
}

class _BaggageDetailPageState extends State<BaggageDetailPage> {
  static const _clockInterval = Duration(seconds: 30);

  BaggageTracking _tracking = BaggageTracking(const []);
  bool _loading = true;
  bool _saving = false;
  bool _fromCache = false;
  String? _error;
  DateTime _now = DateTime.now();
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _clock = Timer.periodic(_clockInterval, (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!_loading) setState(() => _loading = true);
    try {
      final result =
          await widget.repository.getEventsForBaggage(widget.baggage.id);
      if (!mounted) return;
      setState(() {
        _tracking = BaggageTracking(result.events);
        _fromCache = result.fromCache;
        _error = null;
        _loading = false;
        _now = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los eventos: $e';
        _loading = false;
      });
    }
  }

  Future<void> _register(BaggageEventType type) async {
    final now = DateTime.now();
    final event = BaggageEvent(
      id: '${widget.baggage.id}-${now.millisecondsSinceEpoch}',
      baggageId: widget.baggage.id,
      type: type.code,
      createdAt: now,
    );

    setState(() => _saving = true);
    try {
      await widget.repository.registerEvent(event);
      if (!mounted) return;
      _showMessage('Evento registrado: ${type.label}.');
      await _loadEvents();
    } on RegisterEventException catch (e) {
      if (!mounted) return;
      _showMessage(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo registrar el evento: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Permite intentar cualquier tipo de evento. El Repository valida la
  /// transicion y rechaza las que saltan o repiten estados.
  Future<void> _chooseOtherType() async {
    final type = await showModalBottomSheet<BaggageEventType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Registrar otro tipo de evento',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Solo se acepta el siguiente estado de la '
                  'secuencia.'),
            ),
            for (final type in BaggageEventType.values)
              ListTile(
                leading: Text('${type.index + 1}'),
                title: Text(type.label),
                subtitle: Text(type.code),
                onTap: () => Navigator.of(context).pop(type),
              ),
          ],
        ),
      ),
    );
    if (type != null) await _register(type);
  }

  void _showMessage(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final baggage = widget.baggage;

    return Scaffold(
      appBar: AppBar(
        title: Text(baggage.id),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _loading || _saving ? null : _loadEvents,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
            ],
            if (_fromCache) ...[
              const CachedDataBanner(),
              const SizedBox(height: 12),
            ],
            _BaggageHeader(baggage: baggage, tracking: _tracking, now: _now),
            const SizedBox(height: 24),
            Text(
              'Historial de eventos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            if (_tracking.history.isEmpty)
              const _EmptyHistory()
            else
              _History(history: _tracking.history),
            const SizedBox(height: 18),
            if (!_loading) ..._buildActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    final next = _tracking.nextType;

    return [
      if (next != null) ...[
        Text(
          'Siguiente evento valido: ${next.label} (${next.code})',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _saving ? null : () => _register(next),
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: Text(
            _tracking.history.isEmpty
                ? 'Registrar primer evento'
                : 'Registrar siguiente evento',
          ),
        ),
      ] else
        _JourneyFinished(isDelivered: _tracking.isDelivered),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: _saving ? null : _chooseOtherType,
        icon: const Icon(Icons.list_alt),
        label: const Text('Elegir otro tipo de evento'),
      ),
    ];
  }
}

class _BaggageHeader extends StatelessWidget {
  const _BaggageHeader({
    required this.baggage,
    required this.tracking,
    required this.now,
  });

  final Baggage baggage;
  final BaggageTracking tracking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final lastEvent = tracking.lastEvent;
    final isDelayed = tracking.isDelayed(now);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.luggage,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baggage.id,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          StatusChip(label: tracking.statusLabel),
                          if (isDelayed)
                            DelayedChip(
                              elapsed: tracking.timeSinceLastUpdate(now)!,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (lastEvent != null) ...[
              const SizedBox(height: 10),
              Text(
                'Ultima actualizacion: ${formatDateTime(lastEvent.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: _InfoField(
                    label: 'Pasajero',
                    value: baggage.passenger,
                  ),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'Vuelo',
                    value: baggage.flight,
                  ),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'Destino',
                    value: baggage.destination,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Historial del equipaje, del evento mas antiguo al mas reciente.
class _History extends StatelessWidget {
  const _History({required this.history});

  final List<BaggageEvent> history;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < history.length; i++)
            ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: i == history.length - 1
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                foregroundColor: i == history.length - 1
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                child: Text('${i + 1}'),
              ),
              title: Text(
                BaggageEventType.fromCode(history[i].type)?.label ??
                    history[i].type,
              ),
              subtitle: Text(
                '${history[i].type} · ${formatDateTime(history[i].createdAt)}',
              ),
              trailing: i == history.length - 1
                  ? Text(
                      'Actual',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

class _JourneyFinished extends StatelessWidget {
  const _JourneyFinished({required this.isDelivered});

  final bool isDelivered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isDelivered ? Icons.check_circle : Icons.help_outline,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isDelivered
                  ? 'Recorrido finalizado: el equipaje fue entregado.'
                  : 'El ultimo evento tiene un tipo desconocido; no hay un '
                      'siguiente evento valido.',
              style: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Este equipaje aun no tiene eventos.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
