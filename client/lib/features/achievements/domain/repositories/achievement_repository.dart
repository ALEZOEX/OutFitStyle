// features/achievements/domain/repositories/achievement_repository.dart
abstract class AchievementRepository {
  // Получить все достижения
  Future<List<Achievement>> getAllAchievements();

  // Получить достижения пользователя
  Future<List<Achievement>> getUserAchievements();

  // Получить прогресс по достижению
  Future<AchievementProgress> getAchievementProgress(String achievementId);

  // Обновить прогресс по достижению
  Future<AchievementProgress> updateAchievementProgress(
    String achievementId, 
    int increment
  );

  // Отметить достижение как разблокированное
  Future<void> unlockAchievement(String achievementId);

  // Отслеживать изменения в прогрессе достижений
  Stream<List<Achievement>> watchAchievements();
}