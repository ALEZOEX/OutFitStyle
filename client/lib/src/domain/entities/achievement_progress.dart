// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_progress.freezed.dart';

@freezed
class AchievementProgress with _$AchievementProgress {
  const factory AchievementProgress({
    int? id,
    @JsonKey(name: 'achievement_id') int? achievementId,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'current_value') int? currentValue,
    @JsonKey(name: 'is_unlocked') bool? isUnlocked,
    @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
  }) = _AchievementProgress;
}
