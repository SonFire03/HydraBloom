import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/hydration_settings.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const bool _safeModeDisableNotifications = false;
  bool _initialized = false;

  static const _channelId = 'hydrabloom_reminders';

  static const List<String> _defaultMessages = [
    '💧 Petite pause eau, hydrate-toi un peu 💕',
    '🌸 Ton corps réclame un petit verre d\'eau',
    '✨ Check hydratation : un verre et tu repars',
    '🩷 Mini rappel mignon : eau time',
    '🌷 Bois un peu, ta fleur intérieure te dit merci',
    '💦 Un petit verre maintenant, glow-up plus tard',
  ];

  static const List<String> _heatMessages = [
    '☀️ Il fait chaud, bois un peu d\'eau',
    '☀️ Chaleur activée : hydrate-toi maintenant',
    '💧 Soleil + eau = combo gagnant',
    '🌡️ Rappel chaleur : un verre fraicheur',
  ];
  static const List<String> _adhdMessages = [
    '💧 Eau maintenant ?',
    'Un verre, puis fini.',
    'Hydrate-toi vite fait.',
    'Petit reset: eau.',
  ];

  Future<void> init() async {
    if (_safeModeDisableNotifications) return;
    if (_initialized) return;
    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(settings);

      final notifGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      debugPrint('HydraBloom notif permission: $notifGranted');

      final exactGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      debugPrint('HydraBloom exact alarm permission: $exactGranted');
      _initialized = true;
    } catch (e) {
      debugPrint('HydraBloom notifications init failed: $e');
      _initialized = false;
    }
  }

  Future<void> cancelAll() async {
    if (_safeModeDisableNotifications) return;
    if (!_initialized) {
      await init();
      if (!_initialized) return;
    }
    try {
      await _plugin.cancelAll();
    } on PlatformException catch (e) {
      // Some older/corrupted scheduled entries can break cancelAll on Android.
      // We keep startup resilient and continue with fresh scheduling.
      debugPrint('HydraBloom cancelAll warning: $e');
    }
  }

  Future<void> showTestNotification() async {
    if (_safeModeDisableNotifications) return;
    if (!_initialized) {
      await init();
      if (!_initialized) return;
    }
    try {
      await _plugin.show(
        999,
        'HydraBloom',
        'Test notification : pense à boire un verre d’eau 💧',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Hydration Reminders',
            channelDescription: 'Gentle reminders to drink water',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint('HydraBloom test notification failed: $e');
    }
  }

  Future<void> scheduleReminders(HydrationSettings settings) async {
    if (_safeModeDisableNotifications) return;
    if (!_initialized) {
      await init();
      if (!_initialized) return;
    }
    await cancelAll();

    if (!settings.reminderEnabled) return;

    // TODO(hydrabloom): replace fixed planning window with resilient background re-scheduler.
    final now = DateTime.now();
    final interval = Duration(minutes: settings.reminderIntervalMinutes);
    final until = now.add(const Duration(days: 2));

    int id = 1000;
    DateTime cursor = now.add(interval);

    while (cursor.isBefore(until)) {
      if (!_isQuietHour(cursor, settings.quietStartHour, settings.quietEndHour)) {
        try {
          await _plugin.zonedSchedule(
            id++,
            'HydraBloom',
            _pickMessage(settings.heatModeEnabled, settings.adhdModeEnabled),
            tz.TZDateTime.from(cursor, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                'Hydration Reminders',
                channelDescription: 'Gentle reminders to drink water',
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (e) {
          debugPrint('HydraBloom schedule failed for one reminder: $e');
        }
      }
      cursor = cursor.add(interval);
    }
  }

  bool _isQuietHour(DateTime time, int start, int end) {
    final h = time.hour;
    if (start == end) return false;
    if (start < end) return h >= start && h < end;
    return h >= start || h < end;
  }

  String _pickMessage(bool heatMode, bool adhdMode) {
    final random = Random();
    final source = adhdMode
        ? _adhdMessages
        : (heatMode ? [..._defaultMessages, ..._heatMessages] : _defaultMessages);
    return source[random.nextInt(source.length)];
  }
}
