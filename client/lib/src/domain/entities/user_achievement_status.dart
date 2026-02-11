// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/achievement_status.dart';

part 'user_achievement_status.freezed.dart';

@freezed
class UserAchievementStatus with _$UserAchievementStatus {
  const factory UserAchievementStatus({
    int? id,
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'achievement_id') int? achievementId,
    AchievementStatus? status,
    int? progress,
    @JsonKey(name: 'achieved_at') DateTime? achievedAt,
  }) = _UserAchievementStatus;
}
