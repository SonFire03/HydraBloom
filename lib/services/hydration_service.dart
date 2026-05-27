import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/badge_model.dart';
import '../models/hydration_day.dart';
import '../models/hydration_settings.dart';
import 'notification_service.dart';
import 'storage_service.dart';

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
  double get progress =>
      settings.dailyGoalMl == 0 ? 0 : (todayIntakeMl / settings.dailyGoalMl).clamp(0, 1).toDouble();
  int get progressPercent => (progress * 100).round();

  String get todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get progressLabel {
    if (progressPercent >= 100) return 'Objectif atteint, bravo 👑';
    if (progressPercent >= 75) return 'Presque au top ✨';
    if (progressPercent >= 50) return 'Mi-parcours, ta fleur pousse 🌸';
    if (progressPercent >= 25) return 'Bien lancée, continue comme ça 💧';
    return 'On commence doucement 🌱';
  }

  String get dailyGentleSummary {
    if (progress >= 1) return 'Super journee: objectif atteint. Fier(e) de toi.';
    if (progress >= 0.7) return 'Tres bien avance. Un petit effort et c est gagne.';
    if (progress >= 0.4) return 'Bonne progression. Continue a ton rythme.';
    return 'On reprend tranquillement, un verre a la fois.';
  }

  List<BadgeModel> get badges => _baseBadges
      .map((badge) {
        final current = _badgeCurrentValue(badge.id);
        final unlocked = unlockedBadgeIds.contains(badge.id) || current >= badge.target;
        return badge.copyWith(
          current: current,
          unlocked: unlocked,
        );
      })
      .toList(growable: false);

  List<HydrationDay> get last7Days {
    // TODO(hydrabloom): expose a repository interface for Android Home Widget sync.
    final sorted = [...history]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    return sorted.take(7).toList(growable: false);
  }

  Future<void> addGlass() async {
    await _rolloverIfNeeded();

    todayGlasses += 1;
    await _storage.saveTodayGlasses(todayGlasses);
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
      settings = HydrationSettings.fromJson((map['settings'] ?? {}) as Map<String, dynamic>);
      todayGlasses = (map['todayGlasses'] ?? 0) as int;
      streak = (map['streak'] ?? 0) as int;
      final hist = (map['history'] ?? <dynamic>[]) as List<dynamic>;
      history = hist.map((e) => HydrationDay.fromJson((e as Map).cast<String, dynamic>())).toList();
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

    if (yesterdayDay.achieved) {
      if (await _isNextDayAfterLastStreak(savedDate)) {
        streak += 1;
      } else {
        streak = 1;
      }
      await _storage.saveStreak(streak);
      await _storage.saveLastStreakDate(savedDate);
    } else {
      streak = 0;
      await _storage.saveStreak(streak);
    }

    todayGlasses = 0;
    await _storage.saveTodayGlasses(0);
    await _storage.saveTodayDate(todayKey);
  }

  Future<bool> _isNextDayAfterLastStreak(String currentDateKey) async {
    final last = await _storage.loadLastStreakDate();
    if (last == null) return true;
    final current = DateFormat('yyyy-MM-dd').parse(currentDateKey);
    final prev = DateFormat('yyyy-MM-dd').parse(last);
    return current.difference(prev).inDays == 1;
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
        return _totalGoalsAchieved;
      case 'streak_bronze':
      case 'streak_silver':
      case 'streak_gold':
        return streak;
      case 'glasses_bronze':
      case 'glasses_silver':
      case 'glasses_gold':
        return _totalGlasses;
      case 'heat_mode_master':
        return _heatModeGoalsAchieved;
      default:
        return 0;
    }
  }

  int get _totalGlasses {
    final historyGlasses = history.fold<int>(0, (sum, day) => sum + (day.intakeMl ~/ settings.glassSizeMl));
    return historyGlasses + todayGlasses;
  }

  int get _totalGoalsAchieved {
    final historyGoals = history.where((day) => day.achieved).length;
    final todayGoal = todayIntakeMl >= settings.dailyGoalMl ? 1 : 0;
    return historyGoals + todayGoal;
  }

  int get _heatModeGoalsAchieved {
    final historyGoals = history.where((day) => day.achieved).length;
    final todayHeatGoal = settings.heatModeEnabled && todayIntakeMl >= settings.dailyGoalMl ? 1 : 0;
    return historyGoals + todayHeatGoal;
  }
}
