import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.streak,
    this.title = 'Streak actuel',
    this.subtitle,
  });

  final int streak;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Text('🔥')),
        title: Text(title),
        subtitle: Text(subtitle ?? '$streak jour(s) consecutif(s)'),
      ),
    );
  }
}
