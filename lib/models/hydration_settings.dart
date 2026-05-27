class HydrationSettings {
  const HydrationSettings({
    this.dailyGoalMl = 2000,
    this.glassSizeMl = 250,
    this.reminderEnabled = true,
    this.reminderIntervalMinutes = 60,
    this.heatModeEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 8,
    this.themeAccent = 'rose',
    this.adhdModeEnabled = false,
  });

  final int dailyGoalMl;
  final int glassSizeMl;
  final bool reminderEnabled;
  final int reminderIntervalMinutes;
  final bool heatModeEnabled;
  final int quietStartHour;
  final int quietEndHour;
  final String themeAccent;
  final bool adhdModeEnabled;

  HydrationSettings copyWith({
    int? dailyGoalMl,
    int? glassSizeMl,
    bool? reminderEnabled,
    int? reminderIntervalMinutes,
    bool? heatModeEnabled,
    int? quietStartHour,
    int? quietEndHour,
    String? themeAccent,
    bool? adhdModeEnabled,
  }) {
    return HydrationSettings(
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      glassSizeMl: glassSizeMl ?? this.glassSizeMl,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      heatModeEnabled: heatModeEnabled ?? this.heatModeEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      themeAccent: themeAccent ?? this.themeAccent,
      adhdModeEnabled: adhdModeEnabled ?? this.adhdModeEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyGoalMl': dailyGoalMl,
        'glassSizeMl': glassSizeMl,
        'reminderEnabled': reminderEnabled,
        'reminderIntervalMinutes': reminderIntervalMinutes,
        'heatModeEnabled': heatModeEnabled,
        'quietStartHour': quietStartHour,
        'quietEndHour': quietEndHour,
        'themeAccent': themeAccent,
        'adhdModeEnabled': adhdModeEnabled,
      };

  factory HydrationSettings.fromJson(Map<String, dynamic> json) {
    return HydrationSettings(
      dailyGoalMl: json['dailyGoalMl'] ?? 2000,
      glassSizeMl: json['glassSizeMl'] ?? 250,
      reminderEnabled: json['reminderEnabled'] ?? true,
      reminderIntervalMinutes: json['reminderIntervalMinutes'] ?? 60,
      heatModeEnabled: json['heatModeEnabled'] ?? false,
      quietStartHour: json['quietStartHour'] ?? 22,
      quietEndHour: json['quietEndHour'] ?? 8,
      themeAccent: json['themeAccent'] ?? 'rose',
      adhdModeEnabled: json['adhdModeEnabled'] ?? false,
    );
  }
}
