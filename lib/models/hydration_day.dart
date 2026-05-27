class HydrationDay {
  const HydrationDay({
    required this.dateKey,
    required this.intakeMl,
    required this.goalMl,
  });

  final String dateKey;
  final int intakeMl;
  final int goalMl;

  bool get achieved => intakeMl >= goalMl;
  double get progress => goalMl <= 0 ? 0 : (intakeMl / goalMl).clamp(0, 1).toDouble();

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'intakeMl': intakeMl,
        'goalMl': goalMl,
      };

  factory HydrationDay.fromJson(Map<String, dynamic> json) {
    return HydrationDay(
      dateKey: json['dateKey'] as String,
      intakeMl: json['intakeMl'] as int,
      goalMl: json['goalMl'] as int,
    );
  }
}
