import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hydration_day.dart';
import '../services/hydration_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HydrationService>();
    final days = service.last7Days;
    final all = [...service.history]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    final last30 = all.take(30).toList(growable: false);

    if (days.isEmpty) {
      return const Center(child: Text('Pas encore d\'historique.'));
    }

    final avg7 = _avgIntake(days);
    final avg30 = _avgIntake(last30);
    final success7 = days.where((d) => d.achieved).length;
    final success30 = last30.where((d) => d.achieved).length;

    return ListView(
      children: [
        _StatsCard(
          avg7: avg7,
          avg30: avg30,
          success7: success7,
          total7: days.length,
          success30: success30,
          total30: last30.length,
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '7 derniers jours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...days.map((day) => _DayBar(day: day)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _avgIntake(List<HydrationDay> days) {
    if (days.isEmpty) return 0;
    final total = days.fold<int>(0, (sum, day) => sum + day.intakeMl);
    return (total / days.length).round();
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.avg7,
    required this.avg30,
    required this.success7,
    required this.total7,
    required this.success30,
    required this.total30,
  });

  final int avg7;
  final int avg30;
  final int success7;
  final int total7;
  final int success30;
  final int total30;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Résumé hydratation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text('Moyenne 7 jours: $avg7 ml'),
            Text('Moyenne 30 jours: $avg30 ml'),
            Text('Objectifs atteints (7j): $success7/$total7'),
            Text('Objectifs atteints (30j): $success30/$total30'),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.day});

  final HydrationDay day;

  @override
  Widget build(BuildContext context) {
    final percent = (day.progress * 100).round();
    final label = day.dateKey.length >= 10 ? day.dateKey.substring(5) : day.dateKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 52, child: Text(label)),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: day.progress.clamp(0, 1),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 48, child: Text('$percent%')),
            ],
          ),
          const SizedBox(height: 2),
          Text('${day.intakeMl} ml / ${day.goalMl} ml'),
        ],
      ),
    );
  }
}
