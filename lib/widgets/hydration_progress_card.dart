import 'package:flutter/material.dart';

class HydrationProgressCard extends StatelessWidget {
  const HydrationProgressCard({
    super.key,
    required this.intakeMl,
    required this.goalMl,
    required this.progress,
    required this.label,
  });

  final int intakeMl;
  final int goalMl;
  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression du jour', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 12, borderRadius: BorderRadius.circular(12)),
            const SizedBox(height: 12),
            Text('$intakeMl ml / $goalMl ml', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
