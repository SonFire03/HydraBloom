import 'package:flutter/material.dart';

import '../models/badge_model.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.badge});

  final BadgeModel badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Opacity(
        opacity: badge.unlocked ? 1 : 0.45,
        child: ListTile(
          leading: CircleAvatar(child: Text(badge.emoji)),
          title: Text('${badge.title}${badge.level.isEmpty ? '' : ' ${badge.level}'}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge.description),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: badge.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 4),
              Text('${badge.current}/${badge.target}'),
            ],
          ),
          trailing: Icon(
            badge.unlocked ? Icons.check_circle : Icons.lock_outline,
          ),
        ),
      ),
    );
  }
}
