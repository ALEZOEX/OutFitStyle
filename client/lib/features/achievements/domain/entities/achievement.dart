// features/achievements/domain/entities/achievement.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String icon,
    required String category, // 'wardrobe', 'recommendations', 'social', 'usage'
    required int points,
    required bool isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? maxProgress,
  }) = _Achievement;

  factory Achievement.initial() => const Achievement(
        id: '',
        title: '',
        description: '',
        icon: '⭐',
        category: '',
        points: 0,
        isUnlocked: false,
      );
}

@freezed
class AchievementProgress with _$AchievementProgress {
  const factory AchievementProgress({
    required String achievementId,
    required int currentProgress,
    required int maxProgress,
    required bool isCompleted,
  }) = _AchievementProgress;
}