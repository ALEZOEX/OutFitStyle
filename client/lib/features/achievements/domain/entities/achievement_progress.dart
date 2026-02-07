import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_progress.freezed.dart';
part 'achievement_progress.g.dart';

@freezed
class AchievementProgress with _$AchievementProgress {
  const factory AchievementProgress({
    required String achievementId,
    required int currentProgress,
    required int maxProgress,
    required bool isCompleted,
    DateTime? completedAt,
  }) = _AchievementProgress;

  factory AchievementProgress.fromJson(Map<String, dynamic> json) => _$AchievementProgressFromJson(json);
}