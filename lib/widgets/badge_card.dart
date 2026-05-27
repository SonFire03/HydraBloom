import 'package:flutter/material.dart';

import '../models/badge_model.dart';

class BadgeCard extends StatefulWidget {
  const BadgeCard({super.key, required this.badge});

  final BadgeModel badge;

  @override
  State<BadgeCard> createState() => _BadgeCardState();
}

class _BadgeCardState extends State<BadgeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _unlockController;

  @override
  void initState() {
    super.initState();
    _unlockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
      value: widget.badge.unlocked ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant BadgeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.badge.unlocked && widget.badge.unlocked) {
      _unlockController.forward(from: 0);
    } else if (!widget.badge.unlocked) {
      _unlockController.value = 0;
    }
  }

  @override
  void dispose() {
    _unlockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.badge;
    return Card(
      child: AnimatedBuilder(
        animation: _unlockController,
        builder: (context, child) {
          final pulse = 1 + (0.04 * (1 - _unlockController.value));
          final glow =
              badge.unlocked ? (0.25 + (0.15 * _unlockController.value)) : 0.0;
          return Transform.scale(
            scale: pulse,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: glow > 0
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(glow),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Opacity(
                opacity: badge.unlocked ? 1 : 0.45,
                child: ListTile(
                  leading: CircleAvatar(child: Text(badge.emoji)),
                  title: Text(
                      '${badge.title}${badge.level.isEmpty ? '' : ' ${badge.level}'}'),
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
            ),
          );
        },
      ),
    );
  }
}
