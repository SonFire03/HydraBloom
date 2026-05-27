import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../services/hydration_service.dart';
import '../widgets/cute_action_button.dart';
import '../widgets/flower_progress_widget.dart';
import '../widgets/heat_mode_card.dart';
import '../widgets/hydration_progress_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/water_counter_card.dart';
import 'badges_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _syncTimer;

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _index != 0) return;
      _consumeWidgetPendingAdds();
      context.read<HydrationService>().syncFromStorage();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HydrationService>().syncFromStorage();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _consumeWidgetPendingAdds();
      context.read<HydrationService>().syncFromStorage();
    }
  }

  Future<void> _consumeWidgetPendingAdds() async {
    const widgetChannel = MethodChannel('hydrabloom/widget');
    final service = context.read<HydrationService>();
    final pending =
        await widgetChannel.invokeMethod<int>('consumePendingAddCount') ?? 0;
    if (pending <= 0) return;
    for (var i = 0; i < pending; i++) {
      await service.addGlass();
    }
    await widgetChannel.invokeMethod(
      'syncWidgetCountFromApp',
      service.todayGlasses,
    );
  }

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final hydration = context.watch<HydrationService>();

    final pages = [
      _HomeContent(hydration: hydration),
      const HistoryScreen(),
      const BadgesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('HydraBloom')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined), label: 'Badges'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Paramètres'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.hydration});

  final HydrationService hydration;
  static const _widgetChannel = MethodChannel('hydrabloom/widget');

  @override
  Widget build(BuildContext context) {
    final isGoalReached = hydration.progress >= 1;
    final adhdMode = hydration.settings.adhdModeEnabled;

    return ListView(
      children: [
        Text(
          _buildWelcomeMessage(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (isGoalReached) ...[
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.96, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Objectif atteint aujourd’hui, magnifique 👑',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Center(child: FlowerProgressWidget(progress: hydration.progress)),
        const SizedBox(height: 16),
        HydrationProgressCard(
          intakeMl: hydration.todayIntakeMl,
          goalMl: hydration.settings.dailyGoalMl,
          progress: hydration.progress,
          label: hydration.progressLabel,
        ),
        const SizedBox(height: 10),
        Text(
          hydration.dailyGentleSummary,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (!adhdMode) ...[
          const SizedBox(height: 12),
          WaterCounterCard(
            glasses: hydration.todayGlasses,
            glassSizeMl: hydration.settings.glassSizeMl,
          ),
          const SizedBox(height: 12),
          StreakCard(streak: hydration.streak),
          const SizedBox(height: 12),
          HeatModeCard(
            enabled: hydration.settings.heatModeEnabled,
            onChanged: (value) => hydration.toggleHeatMode(value),
          ),
        ],
        const SizedBox(height: 12),
        CuteActionButton(
          onPressed: () async {
            await hydration.addGlass();
            await _widgetChannel.invokeMethod(
              'syncWidgetCountFromApp',
              hydration.todayGlasses,
            );
            HapticFeedback.lightImpact();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  duration: Duration(milliseconds: 900),
                  content: Text('Bien joue, +1 verre 💧'),
                ),
              );
            }
          },
          label: 'J\'ai bu un verre 💧',
        ),
        if (adhdMode) ...[
          const SizedBox(height: 10),
          Text(
            'Mode TDAH: une action simple, puis on avance.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  String _buildWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hydration.progress >= 1) {
      return 'Tu as déjà géré ton hydratation aujourd’hui.';
    }
    if (hour < 12) {
      return 'Bonjour, on commence en douceur avec un verre d’eau ?';
    }
    if (hour < 18) return 'Bon après-midi, pense à t’hydrater régulièrement.';
    return 'Bonsoir, encore un petit verre avant la fin de journée ?';
  }
}
