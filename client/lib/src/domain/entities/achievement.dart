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
    required bool isCompleted,
    required DateTime? completedAt,
    required int progress,
    required int target,
    required String reward,
    required bool isVisible,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String userId,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);
}