import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_category.dart';
import 'achievement_definitions.dart';

/// Фильтр для списка достижений
enum AchievementFilter {
  /// Все достижения
  all('Все'),

  /// Доступные (не разблокированные)
  available('Доступные'),

  /// Полученные (разблокированные)
  unlocked('Полученные');

  final String displayName;
  const AchievementFilter(this.displayName);
}

/// Репозиторий для работы с достижениями
class AchievementsRepository {
  final List<Achievement> _achievements = [];
  final _streamController = StreamController<List<Achievement>>.broadcast();

  /// Stream для отслеживания изменений достижений
  Stream<List<Achievement>> get achievementsStream => _streamController.stream;

  /// Текущий список достижений
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  AchievementsRepository() {
    _loadAchievements();
  }

  /// Загрузить достижения из определений
  void _loadAchievements() {
    _achievements.clear();
    _achievements.addAll(AchievementDefinitions.getAllAchievements());
    _notifyListeners();
  }

  /// Получить все достижения
  List<Achievement> getAllAchievements() {
    return List.unmodifiable(_achievements);
  }

  /// Получить достижения по категории
  List<Achievement> getByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  /// Получить достижения с фильтром
  List<Achievement> getWithFilter(AchievementFilter filter) {
    switch (filter) {
      case AchievementFilter.available:
        return _achievements.where((a) => !a.isUnlocked).toList();
      case AchievementFilter.unlocked:
        return _achievements.where((a) => a.isUnlocked).toList();
      case AchievementFilter.all:
      default:
        return List.unmodifiable(_achievements);
    }
  }

  /// Получить достижение по ID
  Achievement? getById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Обновить прогресс достижения
  Future<Achievement?> updateProgress(
    String achievementId,
    int progress,
  ) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return null;

    final achievement = _achievements[index];
    final newProgress = progress.clamp(0, achievement.targetValue);
    final isNowUnlocked = newProgress >= achievement.targetValue;

    // Если уже было разблокировано, не меняем unlockedAt
    final wasUnlocked = achievement.isUnlocked;

    final updated = achievement.copyWith(
      currentProgress: newProgress,
      isUnlocked: isNowUnlocked,
      unlockedAt:
          isNowUnlocked && !wasUnlocked
              ? DateTime.now()
              : achievement.unlockedAt,
      updatedAt: DateTime.now(),
    );

    _achievements[index] = updated;
    _notifyListeners();

    // Возвращаем достижение только если оно только что разблокировано
    return isNowUnlocked && !wasUnlocked ? updated : null;
  }

  /// Увеличить прогресс достижения на указанное значение
  Future<Achievement?> incrementProgress(
    String achievementId, {
    int by = 1,
  }) async {
    final achievement = getById(achievementId);
    if (achievement == null) return null;

    return updateProgress(achievementId, achievement.currentProgress + by);
  }

  /// Разблокировать достижение напрямую
  Future<void> unlockAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    final updated = achievement.copyWith(
      currentProgress: achievement.targetValue,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _achievements[index] = updated;
    _notifyListeners();
  }

  /// Сбросить прогресс достижения
  Future<void> resetProgress(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _achievements[index];
    final updated = achievement.copyWith(
      currentProgress: 0,
      isUnlocked: false,
      unlockedAt: null,
      updatedAt: DateTime.now(),
    );

    _achievements[index] = updated;
    _notifyListeners();
  }

  /// Получить статистику достижений
  AchievementStats getStats() {
    final total = _achievements.length;
    final unlocked = _achievements.where((a) => a.isUnlocked).length;
    final totalPoints = _achievements.fold<int>(0, (sum, a) => sum + a.points);
    final earnedPoints = _achievements
        .where((a) => a.isUnlocked)
        .fold<int>(0, (sum, a) => sum + a.points);

    return AchievementStats(
      totalAchievements: total,
      unlockedAchievements: unlocked,
      totalPoints: totalPoints,
      earnedPoints: earnedPoints,
      progressPercent: total > 0 ? (unlocked / total * 100) : 0,
    );
  }

  /// Получить прогресс по категории
  CategoryProgress getCategoryProgress(AchievementCategory category) {
    final categoryAchievements = getByCategory(category);
    final unlocked = categoryAchievements.where((a) => a.isUnlocked).length;

    return CategoryProgress(
      category: category,
      total: categoryAchievements.length,
      unlocked: unlocked,
      progressPercent:
          categoryAchievements.isNotEmpty
              ? (unlocked / categoryAchievements.length * 100)
              : 0,
    );
  }

  /// Уведомить слушателей об изменениях
  void _notifyListeners() {
    if (!_streamController.isClosed) {
      _streamController.add(List.unmodifiable(_achievements));
    }
  }

  /// Освободить ресурсы
  void dispose() {
    _streamController.close();
  }
}

/// Статистика достижений
class AchievementStats {
  final int totalAchievements;
  final int unlockedAchievements;
  final int totalPoints;
  final int earnedPoints;
  final double progressPercent;

  const AchievementStats({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.totalPoints,
    required this.earnedPoints,
    required this.progressPercent,
  });

  /// Общий прогресс в формате "X/Y"
  String get progressText => '$unlockedAchievements/$totalAchievements';

  /// Заработанные очки в формате "X/Y"
  String get pointsText => '$earnedPoints/$totalPoints';
}

/// Прогресс категории
class CategoryProgress {
  final AchievementCategory category;
  final int total;
  final int unlocked;
  final double progressPercent;

  const CategoryProgress({
    required this.category,
    required this.total,
    required this.unlocked,
    required this.progressPercent,
  });

  /// Прогресс в формате "X/Y"
  String get progressText => '$unlocked/$total';
}
