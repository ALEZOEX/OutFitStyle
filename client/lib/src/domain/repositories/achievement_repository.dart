import 'package:dartz/dartz.dart';
import '../entities/achievement.dart';
import '../entities/achievement_progress.dart';
import '../entities/user_achievement_status.dart';
import '../enums/achievement_status.dart';

abstract class AchievementRepository {
  Future<Either<String, List<Achievement>>> getAllAchievements();

  Future<Either<String, List<AchievementProgress>>> getUserAchievements(
      int userId);

  Future<Either<String, AchievementProgress>> updateUserAchievement({
    required int userId,
    required int achievementId,
    required int progress,
  });

  Future<Either<String, AchievementProgress>> unlockAchievement({
    required int userId,
    required int achievementId,
  });

  Future<Either<String, List<UserAchievementStatus>>> getUserAchievementStatus(
      int userId);

  Future<Either<String, UserAchievementStatus>> setUserAchievementStatus({
    required int userId,
    required int achievementId,
    required AchievementStatus status,
    int? progress,
  });

  Future<Either<String, AchievementProgress>> incrementUserAchievementProgress({
    required int userId,
    required int achievementId,
    int incrementBy = 1,
  });

  Future<Either<String, List<Achievement>>> getUserUnlockedAchievements(
      int userId);

  Future<Either<String, List<Achievement>>> getUserLockedAchievements(
      int userId);

  Future<Either<String, List<Achievement>>> getUserInProgressAchievements(
      int userId);

  Future<Either<String, AchievementProgress>> getAchievementProgress({
    required int userId,
    required int achievementId,
  });

  Future<Either<String, void>> resetAchievementProgress({
    required int userId,
    required int achievementId,
  });

  Future<Either<String, void>> awardAchievementReward({
    required int userId,
    required int achievementId,
  });

  Future<Either<String, List<Achievement>>> getAchievements();
}
