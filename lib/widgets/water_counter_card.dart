import 'package:flutter/material.dart';

class WaterCounterCard extends StatelessWidget {
  const WaterCounterCard({
    super.key,
    required this.glasses,
    required this.glassSizeMl,
  });

  final int glasses;
  final int glassSizeMl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verres aujourd\'hui', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text('$glasses verres', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            Text('${glasses * glassSizeMl} ml 💧', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
