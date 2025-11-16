class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredCount;
  final int currentCount;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCount,
    this.currentCount = 0,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;
  double get progress => requiredCount > 0 ? (currentCount / requiredCount).clamp(0.0, 1.0) : 0.0;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      requiredCount: json['required_count'] ?? 0,
      currentCount: json['current_count'] ?? 0,
      unlockedAt: json['unlocked_at'] != null ? DateTime.parse(json['unlocked_at']) : null,
    );
  }
}