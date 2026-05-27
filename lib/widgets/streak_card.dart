import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Text('🔥')),
        title: const Text('Streak actuel'),
        subtitle: Text('$streak jour(s) consecutif(s)'),
      ),
    );
  }
}
