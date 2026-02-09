import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_progress.freezed.dart';
part 'achievement_progress.g.dart';

@freezed
class AchievementProgress with _$AchievementProgress {
  const factory AchievementProgress({
    required String achievementId,
    required String userId,
    required int currentProgress,
    required int targetProgress,
    required bool isCompleted,
    required DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AchievementProgress;

  factory AchievementProgress.fromJson(Map<String, dynamic> json) => _$AchievementProgressFromJson(json);
}