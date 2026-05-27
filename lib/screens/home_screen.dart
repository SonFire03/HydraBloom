import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../l10n/app_strings.dart';
import '../services/hydration_service.dart';
import '../widgets/cute_action_button.dart';
import '../widgets/flower_progress_widget.dart';
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
    final t = AppStrings.of(hydration.settings.languageCode);

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
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_rounded), label: t.t('home')),
          NavigationDestination(
              icon: const Icon(Icons.history), label: t.t('history')),
          NavigationDestination(
              icon: const Icon(Icons.emoji_events_outlined),
              label: t.t('badges')),
          NavigationDestination(
              icon: const Icon(Icons.tune), label: t.t('settings')),
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
    final t = AppStrings.of(hydration.settings.languageCode);
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
                t.t('goalReachedBanner'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Center(
          child: FlowerProgressWidget(
            progress: hydration.progress,
            languageCode: hydration.settings.languageCode,
          ),
        ),
        const SizedBox(height: 16),
        HydrationProgressCard(
          intakeMl: hydration.todayIntakeMl,
          goalMl: hydration.settings.dailyGoalMl,
          progress: hydration.progress,
          label: hydration.progressLabel,
          title: t.t('progressDay'),
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
            title: t.t('waterToday'),
          ),
          const SizedBox(height: 12),
          StreakCard(
            streak: hydration.streak,
            title: t.t('streakCurrent'),
            subtitle: t.t('streakDays', {'count': hydration.streak.toString()}),
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
                SnackBar(
                  duration: const Duration(milliseconds: 900),
                  content: Text(t.t('snackAddedGlass')),
                ),
              );
            }
          },
          label: t.t('drinkButton'),
        ),
        if (adhdMode) ...[
          const SizedBox(height: 10),
          Text(
            t.t('adhdHint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  String _buildWelcomeMessage() {
    final t = AppStrings.of(hydration.settings.languageCode);
    final hour = DateTime.now().hour;
    if (hydration.progress >= 1) {
      return t.t('welcomeGoalReached');
    }
    if (hour < 12) {
      return t.t('welcomeMorning');
    }
    if (hour < 18) return t.t('welcomeAfternoon');
    return t.t('welcomeEvening');
  }
}
