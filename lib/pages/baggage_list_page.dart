import 'dart:async';

import 'package:flutter/material.dart';

import '../data/baggage_seed.dart';
import '../models/baggage.dart';
import '../models/baggage_event.dart';
import '../models/baggage_tracking.dart';
import '../repositories/baggage_event_repository.dart';
import '../widgets/baggage_card.dart';
import '../widgets/cached_data_banner.dart';
import 'baggage_detail_page.dart';

class BaggageListPage extends StatefulWidget {
  const BaggageListPage({super.key, required this.repository});

  final BaggageEventRepository repository;

  @override
  State<BaggageListPage> createState() => _BaggageListPageState();
}

class _BaggageListPageState extends State<BaggageListPage> {
  /// Cada cuanto se recalcula el indicador Demorado sin volver a consultar.
  static const _clockInterval = Duration(seconds: 30);

  Map<String, BaggageTracking> _tracking = const {};
  bool _loading = true;
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
      final result = await widget.repository.getAllEvents();
      final byBaggage = <String, List<BaggageEvent>>{};
      for (final event in result.events) {
        byBaggage.putIfAbsent(event.baggageId, () => []).add(event);
      }
      if (!mounted) return;
      setState(() {
        _tracking = {
          for (final baggage in baggageSeed)
            baggage.id: BaggageTracking(byBaggage[baggage.id] ?? const []),
        };
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

  Future<void> _openDetail(Baggage baggage) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BaggageDetailPage(
          baggage: baggage,
          repository: widget.repository,
        ),
      ),
    );
    // El detalle pudo registrar eventos: se recalculan los estados.
    if (mounted) await _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final delayedCount =
        _tracking.values.where((tracking) => tracking.isDelayed(_now)).length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.luggage_outlined),
            SizedBox(width: 10),
            Text('BaggageTrack'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadEvents,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
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
              if (delayedCount > 0) ...[
                _DelayedSummary(count: delayedCount),
                const SizedBox(height: 12),
              ],
              for (final baggage in baggageSeed) ...[
                _buildCard(baggage),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Baggage baggage) {
    final tracking = _tracking[baggage.id];

    return BaggageCard(
      baggage: baggage,
      statusLabel: tracking?.statusLabel ??
          (_loading ? 'Cargando...' : BaggageTracking.noEventsLabel),
      delayedFor: tracking != null && tracking.isDelayed(_now)
          ? tracking.timeSinceLastUpdate(_now)
          : null,
      onTap: () => _openDetail(baggage),
    );
  }
}

class _DelayedSummary extends StatelessWidget {
  const _DelayedSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.schedule, color: colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            count == 1
                ? '1 equipaje demorado (mas de 30 min sin actualizacion)'
                : '$count equipajes demorados (mas de 30 min sin actualizacion)',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
