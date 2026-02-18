import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String icon,
    required String category,
    required int points,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default(0) int progress,
    @Default(1) int target,
    @Default('') String reward,
    @Default(true) bool isVisible,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? userId,
    @Default(false) bool isUnlocked,
    @Default(0) int currentProgress,
    @Default(1) int targetValue,
    DateTime? unlockedAt,
    String? type,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
}