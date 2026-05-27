import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/hydration_service.dart';
import '../widgets/badge_card.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = context.watch<HydrationService>().badges;

    return ListView.separated(
      itemCount: badges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => BadgeCard(badge: badges[index]),
    );
  }
}
