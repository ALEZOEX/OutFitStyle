// ignore_for_file: invalid_annotation_target
// lib/src/domain/entities/achievement.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/achievement_type.dart';
import '../enums/specific_achievement_type.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    int? id,
    String? title,
    String? description,
    String? icon,
    @Default(AchievementType.progress) AchievementType type,
    @JsonKey(name: 'specific_type') SpecificAchievementType? specificType,
    @JsonKey(name: 'target_progress') int? targetProgress,
    @JsonKey(name: 'current_progress') @Default(0) int currentProgress,
    @JsonKey(name: 'is_unlocked') @Default(false) bool isUnlocked,
    @JsonKey(name: 'is_visible') @Default(false) bool isVisible,
    @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
    String? reward,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}
