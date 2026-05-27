import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_strings.dart';
import '../models/hydration_settings.dart';
import '../services/hydration_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HydrationService>();
    final settings = service.settings;
    final t = AppStrings.of(settings.languageCode);

    Future<void> save(HydrationSettings next) => service.updateSettings(next);

    return ListView(
      children: [
        Card(
          child: SwitchListTile(
            value: settings.reminderEnabled,
            onChanged: (v) => save(settings.copyWith(reminderEnabled: v)),
            title: Text(t.t('remindersOn')),
          ),
        ),
        Card(
          child: SwitchListTile(
            value: settings.adhdModeEnabled,
            onChanged: (v) {
              save(
                settings.copyWith(
                  adhdModeEnabled: v,
                  reminderIntervalMinutes:
                      v ? 45 : settings.reminderIntervalMinutes,
                  dailyGoalMl: v
                      ? settings.dailyGoalMl.clamp(1200, 2200)
                      : settings.dailyGoalMl,
                ),
              );
            },
            title: Text(t.t('adhdMode')),
            subtitle: Text(t.t('adhdModeSub')),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(t.t('language')),
            trailing: DropdownButton<String>(
              value: settings.languageCode,
              items: AppStrings.supportedLanguageCodes
                  .map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(t.t('lang_$code')),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  save(settings.copyWith(languageCode: v));
                }
              },
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(t.t('dailyGoal')),
            subtitle: Text('${settings.dailyGoalMl} ml'),
            trailing: _NumberAdjuster(
              onMinus: () => save(settings.copyWith(
                dailyGoalMl: (settings.dailyGoalMl - 100).clamp(500, 6000),
              )),
              onPlus: () => save(settings.copyWith(
                dailyGoalMl: (settings.dailyGoalMl + 100).clamp(500, 6000),
              )),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.t('quickGoals')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1500, 2000, 2500].map((goal) {
                    final selected = settings.dailyGoalMl == goal;
                    return ChoiceChip(
                      label: Text(
                          '${goal ~/ 1000}${goal % 1000 == 0 ? '' : '.5'} L'),
                      selected: selected,
                      onSelected: (_) =>
                          save(settings.copyWith(dailyGoalMl: goal)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(t.t('glassSize')),
            subtitle: Text('${settings.glassSizeMl} ml'),
            trailing: _NumberAdjuster(
              onMinus: () => save(settings.copyWith(
                glassSizeMl: (settings.glassSizeMl - 50).clamp(100, 1000),
              )),
              onPlus: () => save(settings.copyWith(
                glassSizeMl: (settings.glassSizeMl + 50).clamp(100, 1000),
              )),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.t('quickSizes')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [200, 250, 300, 350].map((size) {
                    return ChoiceChip(
                      label: Text('$size ml'),
                      selected: settings.glassSizeMl == size,
                      onSelected: (_) =>
                          save(settings.copyWith(glassSizeMl: size)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(t.t('reminderInterval')),
            subtitle: Text('${settings.reminderIntervalMinutes} min'),
            trailing: DropdownButton<int>(
              value: settings.reminderIntervalMinutes,
              items: const [30, 45, 60, 120]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e min')))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  save(settings.copyWith(reminderIntervalMinutes: v));
                }
              },
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(t.t('quietHours')),
            subtitle:
                Text('${settings.quietStartHour}h - ${settings.quietEndHour}h'),
            trailing: TextButton(
              onPressed: () async {
                final start = await _pickHour(context, settings.quietStartHour);
                if (start == null || !context.mounted) return;
                final end = await _pickHour(context, settings.quietEndHour);
                if (end == null) return;
                await save(settings.copyWith(
                    quietStartHour: start, quietEndHour: end));
              },
              child: Text(t.t('edit')),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.t('themeColor')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: const [
                    ('rose', 'Rose'),
                    ('mint', 'Menthe'),
                    ('ocean', 'Océan'),
                    ('coral', 'Corail'),
                  ].map((entry) {
                    final key = entry.$1;
                    final label = entry.$2;
                    return ChoiceChip(
                      label: Text(label),
                      selected: settings.themeAccent == key,
                      onSelected: (_) =>
                          save(settings.copyWith(themeAccent: key)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 230,
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  t.t('loveCard'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => service.sendTestNotification(),
          icon: const Icon(Icons.notifications_active_outlined),
          label: Text(t.t('testNotification')),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final json = await service.exportBackupJson();
            if (!context.mounted) return;
            await Clipboard.setData(ClipboardData(text: json));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.t('backupCopied'))),
            );
          },
          icon: const Icon(Icons.download_rounded),
          label: Text(t.t('exportBackup')),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final controller = TextEditingController();
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(t.t('importBackup')),
                content: TextField(
                  controller: controller,
                  minLines: 6,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'JSON',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(t.t('cancel'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(t.t('import'))),
                ],
              ),
            );
            if (ok == true) {
              final success = await service.importBackupJson(controller.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        success ? t.t('backupImported') : t.t('invalidJson'))),
              );
            }
          },
          icon: const Icon(Icons.upload_rounded),
          label: Text(t.t('importBackup')),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () => service.resetToday(),
          child: Text(t.t('resetToday')),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => service.resetAll(),
          child: Text(t.t('resetAll')),
        ),
      ],
    );
  }

  Future<int?> _pickHour(BuildContext context, int initialHour) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: 0),
    );
    return time?.hour;
  }
}

class _NumberAdjuster extends StatelessWidget {
  const _NumberAdjuster({required this.onMinus, required this.onPlus});

  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline)),
        IconButton(
            onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
      ],
    );
  }
}
