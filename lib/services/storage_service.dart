import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _settingsKey = 'settings';
  static const _todayKey = 'today_glasses';
  static const _todayDateKey = 'today_date';
  static const _historyKey = 'history_days';
  static const _streakKey = 'streak_count';
  static const _lastStreakDateKey = 'last_streak_date';
  static const _unlockedBadgesKey = 'unlocked_badges';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Map<String, dynamic>?> loadSettings() async {
    final raw = (await _prefs).getString(_settingsKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await (await _prefs).setString(_settingsKey, jsonEncode(settings));
  }

  Future<int> loadTodayGlasses() async => (await _prefs).getInt(_todayKey) ?? 0;

  Future<void> saveTodayGlasses(int glasses) async {
    await (await _prefs).setInt(_todayKey, glasses);
  }

  Future<String?> loadTodayDate() async => (await _prefs).getString(_todayDateKey);

  Future<void> saveTodayDate(String dateKey) async {
    await (await _prefs).setString(_todayDateKey, dateKey);
  }

  Future<List<Map<String, dynamic>>> loadHistory() async {
    final raw = (await _prefs).getStringList(_historyKey) ?? <String>[];
    return raw
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList(growable: false);
  }

  Future<void> saveHistory(List<Map<String, dynamic>> days) async {
    final raw = days.map(jsonEncode).toList(growable: false);
    await (await _prefs).setStringList(_historyKey, raw);
  }

  Future<int> loadStreak() async => (await _prefs).getInt(_streakKey) ?? 0;

  Future<void> saveStreak(int streak) async {
    await (await _prefs).setInt(_streakKey, streak);
  }

  Future<String?> loadLastStreakDate() async =>
      (await _prefs).getString(_lastStreakDateKey);

  Future<void> saveLastStreakDate(String dateKey) async {
    await (await _prefs).setString(_lastStreakDateKey, dateKey);
  }

  Future<Set<String>> loadUnlockedBadges() async {
    final values = (await _prefs).getStringList(_unlockedBadgesKey) ?? <String>[];
    return values.toSet();
  }

  Future<void> saveUnlockedBadges(Set<String> ids) async {
    await (await _prefs).setStringList(_unlockedBadgesKey, ids.toList());
  }

  Future<void> resetToday() async {
    await (await _prefs).setInt(_todayKey, 0);
  }

  Future<void> resetAll() async {
    await (await _prefs).clear();
  }
}
