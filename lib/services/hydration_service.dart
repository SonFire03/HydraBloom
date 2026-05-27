import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/badge_model.dart';
import '../models/hydration_day.dart';
import '../models/hydration_settings.dart';
import 'notification_service.dart';
import 'storage_service.dart';
import '../l10n/app_strings.dart';

class HydrationService extends ChangeNotifier {
  HydrationService({
    required StorageService storageService,
    required NotificationService notificationService,
  })  : _storage = storageService,
        _notifications = notificationService;

  final StorageService _storage;
  final NotificationService _notifications;

  HydrationSettings settings = const HydrationSettings();
  int todayGlasses = 0;
  int streak = 0;
  String mood = 'focus';
  DateTime? heatBoostUntil;

  final List<BadgeModel> _baseBadges = const [
    BadgeModel(
      id: 'total_goals_bronze',
      title: 'Objectifs atteints',
      level: 'Bronze',
      emoji: '🥉',
      description: 'Atteins 3 objectifs au total.',
      target: 3,
    ),
    BadgeModel(
      id: 'total_goals_silver',
      title: 'Objectifs atteints',
      level: 'Argent',
      emoji: '🥈',
      description: 'Atteins 10 objectifs au total.',
      target: 10,
    ),
    BadgeModel(
      id: 'total_goals_gold',
      title: 'Objectifs atteints',
      level: 'Or',
      emoji: '🥇',
      description: 'Atteins 30 objectifs au total.',
      target: 30,
    ),
    BadgeModel(
      id: 'streak_bronze',
      title: 'Serie parfaite',
      level: 'Bronze',
      emoji: '🔥',
      description: 'Atteins une serie de 3 jours.',
      target: 3,
    ),
    BadgeModel(
      id: 'streak_silver',
      title: 'Serie parfaite',
      level: 'Argent',
      emoji: '🔥',
      description: 'Atteins une serie de 7 jours.',
      target: 7,
    ),
    BadgeModel(
      id: 'streak_gold',
      title: 'Serie parfaite',
      level: 'Or',
      emoji: '🔥',
      description: 'Atteins une serie de 30 jours.',
      target: 30,
    ),
    BadgeModel(
      id: 'glasses_bronze',
      title: 'Verres bus',
      level: 'Bronze',
      emoji: '💧',
      description: 'Bois 50 verres au total.',
      target: 50,
    ),
    BadgeModel(
      id: 'glasses_silver',
      title: 'Verres bus',
      level: 'Argent',
      emoji: '💧',
      description: 'Bois 150 verres au total.',
      target: 150,
    ),
    BadgeModel(
      id: 'glasses_gold',
      title: 'Verres bus',
      level: 'Or',
      emoji: '💧',
      description: 'Bois 400 verres au total.',
      target: 400,
    ),
    BadgeModel(
      id: 'heat_mode_master',
      title: 'Mode chaleur',
      level: 'Maitrise',
      emoji: '☀️',
      description: 'Atteins 5 objectifs en mode chaleur.',
      target: 5,
    ),
    BadgeModel(
      id: 'total_goals_platinum',
      title: 'Objectifs atteints',
      level: 'Platine',
      emoji: '🏆',
      description: 'Atteins 60 objectifs au total.',
      target: 60,
    ),
    BadgeModel(
      id: 'total_goals_diamond',
      title: 'Objectifs atteints',
      level: 'Diamant',
      emoji: '💎',
      description: 'Atteins 120 objectifs au total.',
      target: 120,
    ),
    BadgeModel(
      id: 'streak_legend',
      title: 'Serie parfaite',
      level: 'Legend',
      emoji: '🔥',
      description: 'Atteins une serie de 60 jours.',
      target: 60,
    ),
    BadgeModel(
      id: 'streak_mythic',
      title: 'Serie parfaite',
      level: 'Mythique',
      emoji: '🌟',
      description: 'Atteins une serie de 120 jours.',
      target: 120,
    ),
    BadgeModel(
      id: 'glasses_platinum',
      title: 'Verres bus',
      level: 'Platine',
      emoji: '🥤',
      description: 'Bois 800 verres au total.',
      target: 800,
    ),
    BadgeModel(
      id: 'glasses_diamond',
      title: 'Verres bus',
      level: 'Diamant',
      emoji: '💧',
      description: 'Bois 1500 verres au total.',
      target: 1500,
    ),
    BadgeModel(
      id: 'intake_1l',
      title: 'Volume total',
      level: '1 L',
      emoji: '🫗',
      description: 'Bois 1 000 ml au total.',
      target: 1000,
    ),
    BadgeModel(
      id: 'intake_10l',
      title: 'Volume total',
      level: '10 L',
      emoji: '🫗',
      description: 'Bois 10 000 ml au total.',
      target: 10000,
    ),
    BadgeModel(
      id: 'intake_50l',
      title: 'Volume total',
      level: '50 L',
      emoji: '🚰',
      description: 'Bois 50 000 ml au total.',
      target: 50000,
    ),
    BadgeModel(
      id: 'intake_100l',
      title: 'Volume total',
      level: '100 L',
      emoji: '🌊',
      description: 'Bois 100 000 ml au total.',
      target: 100000,
    ),
    BadgeModel(
      id: 'history_3d',
      title: 'Regularite',
      level: '3 jours',
      emoji: '📅',
      description: 'Suivi actif pendant 3 jours.',
      target: 3,
    ),
    BadgeModel(
      id: 'history_7d',
      title: 'Regularite',
      level: '7 jours',
      emoji: '📅',
      description: 'Suivi actif pendant 7 jours.',
      target: 7,
    ),
    BadgeModel(
      id: 'history_14d',
      title: 'Regularite',
      level: '14 jours',
      emoji: '🗓️',
      description: 'Suivi actif pendant 14 jours.',
      target: 14,
    ),
    BadgeModel(
      id: 'history_30d',
      title: 'Regularite',
      level: '30 jours',
      emoji: '🗓️',
      description: 'Suivi actif pendant 30 jours.',
      target: 30,
    ),
    BadgeModel(
      id: 'history_90d',
      title: 'Regularite',
      level: '90 jours',
      emoji: '📆',
      description: 'Suivi actif pendant 90 jours.',
      target: 90,
    ),
    BadgeModel(
      id: 'heat_mode_apprentice',
      title: 'Mode chaleur',
      level: 'Apprenti',
      emoji: '☀️',
      description: 'Atteins 1 objectif en mode chaleur.',
      target: 1,
    ),
    BadgeModel(
      id: 'heat_mode_adept',
      title: 'Mode chaleur',
      level: 'Adepte',
      emoji: '☀️',
      description: 'Atteins 3 objectifs en mode chaleur.',
      target: 3,
    ),
    BadgeModel(
      id: 'heat_mode_legend',
      title: 'Mode chaleur',
      level: 'Legend',
      emoji: '🌤️',
      description: 'Atteins 10 objectifs en mode chaleur.',
      target: 10,
    ),
    BadgeModel(
      id: 'heat_mode_mythic',
      title: 'Mode chaleur',
      level: 'Mythique',
      emoji: '🌞',
      description: 'Atteins 25 objectifs en mode chaleur.',
      target: 25,
    ),
    BadgeModel(
      id: 'first_glass',
      title: 'Premier pas',
      level: 'Debut',
      emoji: '✨',
      description: 'Bois ton premier verre.',
      target: 1,
    ),
  ];

  List<HydrationDay> history = [];
  Set<String> unlockedBadgeIds = {};

  Future<void> init() async {
    await _notifications.init();

    final settingsJson = await _storage.loadSettings();
    if (settingsJson != null) {
      settings = HydrationSettings.fromJson(settingsJson);
    }

    todayGlasses = await _storage.loadTodayGlasses();
    streak = await _storage.loadStreak();
    unlockedBadgeIds = await _storage.loadUnlockedBadges();

    final historyJson = await _storage.loadHistory();
    history = historyJson.map(HydrationDay.fromJson).toList();

    await _rolloverIfNeeded();
    await _notifications.scheduleReminders(settings);
    await _refreshBadgeUnlocks();
    notifyListeners();
  }

  int get todayIntakeMl => todayGlasses * settings.glassSizeMl;
  double get progress => settings.dailyGoalMl == 0
      ? 0
      : (todayIntakeMl / settings.dailyGoalMl).clamp(0, 1).toDouble();
  int get progressPercent => (progress * 100).round();

  String get todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get progressLabel {
    final t = AppStrings.of(settings.languageCode);
    if (progressPercent >= 100) return t.t('progressLabel100');
    if (progressPercent >= 75) return t.t('progressLabel75');
    if (progressPercent >= 50) return t.t('progressLabel50');
    if (progressPercent >= 25) return t.t('progressLabel25');
    return t.t('progressLabel0');
  }

  String get dailyGentleSummary {
    final t = AppStrings.of(settings.languageCode);
    if (progress >= 1) return t.t('summary100');
    if (progress >= 0.7) return t.t('summary70');
    if (progress >= 0.4) return t.t('summary40');
    return t.t('summary0');
  }

  List<BadgeModel> get badges => _baseBadges.map((badge) {
        final current = _badgeCurrentValue(badge.id);
        final unlocked =
            unlockedBadgeIds.contains(badge.id) || current >= badge.target;
        return badge.copyWith(
          current: current,
          unlocked: unlocked,
        );
      }).toList(growable: false);

  List<HydrationDay> get last7Days {
    // TODO(hydrabloom): expose a repository interface for Android Home Widget sync.
    final sorted = [...history]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return sorted.take(7).toList(growable: false);
  }

  Future<void> addGlass() async {
    await _rolloverIfNeeded();

    final wasGoalReached = progress >= 1;
    todayGlasses += 1;
    await _storage.saveTodayGlasses(todayGlasses);

    final isGoalReachedNow = progress >= 1;
    if (!wasGoalReached && isGoalReachedNow) {
      await _awardStreakForTodayGoal();
    }

    await _refreshBadgeUnlocks();
    notifyListeners();
  }

  Future<void> updateSettings(HydrationSettings value) async {
    settings = value;
    await _storage.saveSettings(settings.toJson());
    await _notifications.scheduleReminders(settings);
    await _refreshBadgeUnlocks();
    notifyListeners();
  }

  Future<void> toggleHeatMode(bool enabled) async {
    final interval = enabled ? 45 : settings.reminderIntervalMinutes;
    await updateSettings(settings.copyWith(
      heatModeEnabled: enabled,
      reminderIntervalMinutes: interval,
    ));
  }

  Future<void> sendTestNotification() async {
    await _notifications.showTestNotification();
  }

  Future<void> syncFromStorage() async {
    final storedTodayGlasses = await _storage.loadTodayGlasses();
    if (storedTodayGlasses != todayGlasses) {
      todayGlasses = storedTodayGlasses;
      notifyListeners();
    }
  }

  Future<void> setMood(String value) async {
    mood = value;
    notifyListeners();
  }

  Future<void> startHeatBoost() async {
    heatBoostUntil = DateTime.now().add(const Duration(hours: 3));
    await updateSettings(settings.copyWith(
      heatModeEnabled: true,
      reminderIntervalMinutes: 30,
    ));
  }

  Future<void> triggerContextRoutine(String routine) async {
    switch (routine) {
      case 'wake':
        await updateSettings(settings.copyWith(reminderIntervalMinutes: 45));
        break;
      case 'meal':
        await addGlass();
        break;
      case 'home':
        await updateSettings(settings.copyWith(reminderIntervalMinutes: 30));
        break;
    }
  }

  Future<String> exportBackupJson() async {
    final data = {
      'settings': settings.toJson(),
      'todayGlasses': todayGlasses,
      'streak': streak,
      'history': history.map((e) => e.toJson()).toList(),
      'unlockedBadges': unlockedBadgeIds.toList(),
      'mood': mood,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<bool> importBackupJson(String raw) async {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      settings = HydrationSettings.fromJson(
          (map['settings'] ?? {}) as Map<String, dynamic>);
      todayGlasses = (map['todayGlasses'] ?? 0) as int;
      streak = (map['streak'] ?? 0) as int;
      final hist = (map['history'] ?? <dynamic>[]) as List<dynamic>;
      history = hist
          .map((e) => HydrationDay.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      final badges = (map['unlockedBadges'] ?? <dynamic>[]) as List<dynamic>;
      unlockedBadgeIds = badges.map((e) => e.toString()).toSet();
      mood = (map['mood'] ?? 'focus').toString();
      await _storage.saveSettings(settings.toJson());
      await _storage.saveTodayGlasses(todayGlasses);
      await _storage.saveStreak(streak);
      await _storage.saveHistory(history.map((e) => e.toJson()).toList());
      await _storage.saveUnlockedBadges(unlockedBadgeIds);
      await _notifications.scheduleReminders(settings);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetToday() async {
    await _saveTodayInHistory();
    todayGlasses = 0;
    await _storage.resetToday();
    await _storage.saveTodayDate(todayKey);
    notifyListeners();
  }

  Future<void> resetAll() async {
    await _storage.resetAll();
    settings = const HydrationSettings();
    todayGlasses = 0;
    streak = 0;
    history = [];
    unlockedBadgeIds = {};
    await _notifications.scheduleReminders(settings);
    await _refreshBadgeUnlocks();
    notifyListeners();
  }

  Future<void> _rolloverIfNeeded() async {
    final savedDate = await _storage.loadTodayDate();
    if (savedDate == null) {
      await _storage.saveTodayDate(todayKey);
      return;
    }

    if (savedDate == todayKey) return;

    final yesterdayDay = HydrationDay(
      dateKey: savedDate,
      intakeMl: todayIntakeMl,
      goalMl: settings.dailyGoalMl,
    );

    history.removeWhere((e) => e.dateKey == savedDate);
    history.add(yesterdayDay);

    history.sort((a, b) => b.dateKey.compareTo(a.dateKey));
    history = history.take(30).toList();

    await _storage.saveHistory(history.map((e) => e.toJson()).toList());

    todayGlasses = 0;
    await _storage.saveTodayGlasses(0);
    await _storage.saveTodayDate(todayKey);
  }

  Future<void> _awardStreakForTodayGoal() async {
    final last = await _storage.loadLastStreakDate();
    if (last == todayKey) return;

    if (last == null) {
      streak = 1;
    } else {
      final current = DateFormat('yyyy-MM-dd').parse(todayKey);
      final prev = DateFormat('yyyy-MM-dd').parse(last);
      streak = current.difference(prev).inDays == 1 ? streak + 1 : 1;
    }

    await _storage.saveStreak(streak);
    await _storage.saveLastStreakDate(todayKey);
  }

  Future<void> _saveTodayInHistory() async {
    history.removeWhere((e) => e.dateKey == todayKey);
    history.add(HydrationDay(
      dateKey: todayKey,
      intakeMl: todayIntakeMl,
      goalMl: settings.dailyGoalMl,
    ));
    await _storage.saveHistory(history.map((e) => e.toJson()).toList());
  }

  Future<void> _refreshBadgeUnlocks() async {
    bool changed = false;
    for (final badge in _baseBadges) {
      final current = _badgeCurrentValue(badge.id);
      if (current >= badge.target && !unlockedBadgeIds.contains(badge.id)) {
        unlockedBadgeIds.add(badge.id);
        changed = true;
      }
    }
    if (changed) {
      await _storage.saveUnlockedBadges(unlockedBadgeIds);
    }
  }

  int _badgeCurrentValue(String badgeId) {
    switch (badgeId) {
      case 'total_goals_bronze':
      case 'total_goals_silver':
      case 'total_goals_gold':
      case 'total_goals_platinum':
      case 'total_goals_diamond':
        return _totalGoalsAchieved;
      case 'streak_bronze':
      case 'streak_silver':
      case 'streak_gold':
      case 'streak_legend':
      case 'streak_mythic':
        return streak;
      case 'glasses_bronze':
      case 'glasses_silver':
      case 'glasses_gold':
      case 'glasses_platinum':
      case 'glasses_diamond':
      case 'first_glass':
        return _totalGlasses;
      case 'intake_1l':
      case 'intake_10l':
      case 'intake_50l':
      case 'intake_100l':
        return _totalIntakeMl;
      case 'history_3d':
      case 'history_7d':
      case 'history_14d':
      case 'history_30d':
      case 'history_90d':
        return _trackedDays;
      case 'heat_mode_apprentice':
      case 'heat_mode_adept':
      case 'heat_mode_master':
      case 'heat_mode_legend':
      case 'heat_mode_mythic':
        return _heatModeGoalsAchieved;
      default:
        return 0;
    }
  }

  int get _totalGlasses {
    final historyGlasses = history.fold<int>(
        0, (sum, day) => sum + (day.intakeMl ~/ settings.glassSizeMl));
    return historyGlasses + todayGlasses;
  }

  int get _totalIntakeMl {
    final historyIntake = history.fold<int>(0, (sum, day) => sum + day.intakeMl);
    return historyIntake + todayIntakeMl;
  }

  int get _trackedDays {
    return history.length + (todayGlasses > 0 ? 1 : 0);
  }

  int get _totalGoalsAchieved {
    final historyGoals = history.where((day) => day.achieved).length;
    final todayGoal = todayIntakeMl >= settings.dailyGoalMl ? 1 : 0;
    return historyGoals + todayGoal;
  }

  int get _heatModeGoalsAchieved {
    final historyGoals = history.where((day) => day.achieved).length;
    final todayHeatGoal =
        settings.heatModeEnabled && todayIntakeMl >= settings.dailyGoalMl
            ? 1
            : 0;
    return historyGoals + todayHeatGoal;
  }
}
