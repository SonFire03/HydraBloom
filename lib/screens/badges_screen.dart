import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/badge_model.dart';
import '../services/hydration_service.dart';
import '../widgets/badge_card.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

enum _BadgeFilter {
  all,
  unlocked,
  inProgress,
  goals,
  streak,
  glasses,
  volume,
  consistency,
  heat,
}

class _BadgesScreenState extends State<BadgesScreen> {
  _BadgeFilter _selectedFilter = _BadgeFilter.all;

  String _labelForFilter(_BadgeFilter filter) {
    switch (filter) {
      case _BadgeFilter.all:
        return 'Tous';
      case _BadgeFilter.unlocked:
        return 'Débloqués';
      case _BadgeFilter.inProgress:
        return 'En cours';
      case _BadgeFilter.goals:
        return 'Objectifs';
      case _BadgeFilter.streak:
        return 'Série';
      case _BadgeFilter.glasses:
        return 'Verres';
      case _BadgeFilter.volume:
        return 'Volume';
      case _BadgeFilter.consistency:
        return 'Régularité';
      case _BadgeFilter.heat:
        return 'Chaleur';
    }
  }

  bool _matchesFilter(BadgeModel badge) {
    switch (_selectedFilter) {
      case _BadgeFilter.all:
        return true;
      case _BadgeFilter.unlocked:
        return badge.unlocked;
      case _BadgeFilter.inProgress:
        return !badge.unlocked;
      case _BadgeFilter.goals:
        return badge.id.startsWith('total_goals');
      case _BadgeFilter.streak:
        return badge.id.startsWith('streak');
      case _BadgeFilter.glasses:
        return badge.id.startsWith('glasses') || badge.id == 'first_glass';
      case _BadgeFilter.volume:
        return badge.id.startsWith('intake_');
      case _BadgeFilter.consistency:
        return badge.id.startsWith('history_');
      case _BadgeFilter.heat:
        return badge.id.startsWith('heat_mode');
    }
  }

  @override
  Widget build(BuildContext context) {
    final badges = context.watch<HydrationService>().badges;
    final filtered = badges.where(_matchesFilter).toList(growable: false);
    const filters = _BadgeFilter.values;

    return Column(
      children: [
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              return ChoiceChip(
                label: Text(_labelForFilter(filter)),
                selected: _selectedFilter == filter,
                onSelected: (_) => setState(() => _selectedFilter = filter),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => BadgeCard(badge: filtered[index]),
          ),
        ),
      ],
    );
  }
}
