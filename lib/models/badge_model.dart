class BadgeModel {
  const BadgeModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    this.level = '',
    this.current = 0,
    this.target = 1,
    this.unlocked = false,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final String level;
  final int current;
  final int target;
  final bool unlocked;

  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  BadgeModel copyWith({
    bool? unlocked,
    int? current,
    int? target,
  }) {
    return BadgeModel(
      id: id,
      title: title,
      emoji: emoji,
      description: description,
      level: level,
      current: current ?? this.current,
      target: target ?? this.target,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
