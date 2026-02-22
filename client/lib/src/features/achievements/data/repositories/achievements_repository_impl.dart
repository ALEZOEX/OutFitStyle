import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/di/di.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_category.dart';
import '../../../../domain/entities/achievement_progress.dart';
import '../../../../domain/entities/user_achievement_status.dart';
import '../../../../domain/enums/achievement_status.dart';
import '../../../../domain/repositories/achievement_repository.dart';
import '../models/achievement_dto.dart';
import '../services/achievements_api_service.dart';
import 'achievement_definitions.dart';
import 'achievements_repository.dart';

/// Репозиторий для работы с достижениями с поддержкой API и offline-first
class AchievementsRepositoryImpl implements AchievementRepository {
  final AchievementsApiService _apiService;
  final List<Achievement> _localCache = [];
  final _streamController = StreamController<List<Achievement>>.broadcast();
  bool _isInitialized = false;
  String? _lastError;

  AchievementsRepositoryImpl(this._apiService) {
    _initialize();
  }

  /// Инициализация репозитория
  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Загружаем все достижения из API
      await _loadAllAchievements();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Ошибка инициализации достижений: $e');
      _lastError = e.toString();
      // Используем локальные определения как fallback
      _loadLocalDefinitions();
    }
  }

  /// Загрузить достижения из API
  Future<void> _loadAllAchievements() async {
    try {
      final response = await _apiService.getAllAchievements();
      final achievements = response.toDomain();

      // Обновляем кэш
      _localCache.clear();
      _localCache.addAll(achievements);

      // Уведомляем слушателей
      _notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки достижений из API: $e');
      rethrow;
    }
  }

  /// Загрузить локальные определения (fallback)
  void _loadLocalDefinitions() {
    _localCache.clear();
    _localCache.addAll(AchievementDefinitions.getAllAchievements());
    _notifyListeners();
  }

  /// Stream для отслеживания изменений достижений
  Stream<List<Achievement>> get achievementsStream => _streamController.stream;

  /// Текущий список достижений
  List<Achievement> get achievements => List.unmodifiable(_localCache);

  /// Получить все достижения
  @override
  Future<Either<String, List<Achievement>>> getAchievements() async {
    try {
      if (!_isInitialized) {
        await _initialize();
      }
      return right(List.unmodifiable(_localCache));
    } catch (e) {
      return left(e.toString());
    }
  }

  /// Получить достижения пользователя из API
  Future<Either<String, UserAchievementsData>> getUserAchievementsData() async {
    try {
      final response = await _apiService.getMyAchievements();
      return right(response.toDomain());
    } catch (e) {
      return left(e.toString());
    }
  }

  /// Трекнуть событие для достижений
  Future<Either<String, List<Achievement>>> trackEvent({
    required String eventType,
    int value = 1,
  }) async {
    try {
      final dtos = await _apiService.trackEvent(eventType: eventType, value: value);

      // Обновляем локальный кэш с новыми данными
      for (final dto in dtos) {
        final domain = dto.toDomain();
        final index = _localCache.indexWhere((a) => a.id == domain.id);
        if (index != -1) {
          _localCache[index] = domain;
        } else {
          _localCache.add(domain);
        }
      }

      if (dtos.isNotEmpty) {
        _notifyListeners();
      }

      return right(dtos.map((d) => d.toDomain()).toList());
    } catch (e) {
      // Если API недоступен, используем локальную логику
      return left(e.toString());
    }
  }

  /// Обновить прогресс достижения (локально)
  Future<Achievement?> updateProgress(String achievementId, int progress) async {
    final index = _localCache.indexWhere((a) => a.id == achievementId);
    if (index == -1) return null;

    final achievement = _localCache[index];
    final newProgress = progress.clamp(0, achievement.targetValue);
    final isNowUnlocked = newProgress >= achievement.targetValue;
    final wasUnlocked = achievement.isUnlocked;

    final updated = achievement.copyWith(
      currentProgress: newProgress,
      isUnlocked: isNowUnlocked,
      unlockedAt: isNowUnlocked && !wasUnlocked ? DateTime.now() : achievement.unlockedAt,
      updatedAt: DateTime.now(),
    );

    _localCache[index] = updated;
    _notifyListeners();

    return isNowUnlocked && !wasUnlocked ? updated : null;
  }

  /// Увеличить прогресс достижения
  Future<Achievement?> incrementProgress(String achievementId, {int by = 1}) async {
    final achievement = getById(achievementId);
    if (achievement == null) return null;

    return updateProgress(achievementId, achievement.currentProgress + by);
  }

  /// Разблокировать достижение напрямую
  @override
  Future<Either<String, AchievementProgress>> unlockAchievement({
    required int userId,
    required int achievementId,
  }) async {
    // Ищем достижение по ID
    final achievement = _localCache.firstWhere(
      (a) => a.id == achievementId.toString(),
      orElse: () => const Achievement(
        id: '0',
        title: 'Unknown',
        description: '',
        icon: '🏆',
        category: AchievementCategory.special,
        points: 0,
      ),
    );

    final updated = achievement.copyWith(
      currentProgress: achievement.targetValue,
      isUnlocked: true,
      unlockedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final index = _localCache.indexWhere((a) => a.id == achievementId.toString());
    if (index != -1) {
      _localCache[index] = updated;
      _notifyListeners();
    }

    // Пытаемся разблокировать на сервере
    try {
      final result = await _apiService.unlockAchievementById(achievementId);
      return result.map((dto) => AchievementProgress(
        achievementId: achievementId.toString(),
        userId: userId.toString(),
        currentProgress: dto.current,
        targetProgress: dto.target,
        isCompleted: dto.isCompleted,
        completedAt: dto.isCompleted ? dto.updatedAt : null,
        createdAt: DateTime.now(),
        updatedAt: dto.updatedAt ?? DateTime.now(),
      ));
    } catch (e) {
      // Возвращаем локальный прогресс (заглушка)
      return right(AchievementProgress(
        achievementId: achievementId.toString(),
        userId: userId.toString(),
        currentProgress: 1,
        targetProgress: 1,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Сбросить прогресс достижения
  Future<void> resetProgress(String achievementId) async {
    final index = _localCache.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    final achievement = _localCache[index];
    final updated = achievement.copyWith(
      currentProgress: 0,
      isUnlocked: false,
      unlockedAt: null,
      updatedAt: DateTime.now(),
    );

    _localCache[index] = updated;
    _notifyListeners();

    // Пытаемся сбросить на сервере
    try {
      await _apiService.resetAchievementProgress(achievementId);
    } catch (e) {
      debugPrint('Ошибка сброса прогресса на сервере: $e');
    }
  }

  /// Получить достижение по ID
  Achievement? getById(String id) {
    try {
      return _localCache.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получить достижения по категории
  List<Achievement> getByCategory(AchievementCategory category) {
    return _localCache.where((a) => a.category == category).toList();
  }

  /// Получить достижения с фильтром
  List<Achievement> getWithFilter(AchievementFilter filter) {
    switch (filter) {
      case AchievementFilter.available:
        return _localCache.where((a) => !a.isUnlocked).toList();
      case AchievementFilter.unlocked:
        return _localCache.where((a) => a.isUnlocked).toList();
      case AchievementFilter.all:
      default:
        return List.unmodifiable(_localCache);
    }
  }

  /// Получить статистику достижений
  AchievementStats getStats() {
    final total = _localCache.length;
    final unlocked = _localCache.where((a) => a.isUnlocked).length;
    final totalPoints = _localCache.fold<int>(0, (sum, a) => sum + a.points);
    final earnedPoints = _localCache
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
      progressPercent: categoryAchievements.isNotEmpty
          ? (unlocked / categoryAchievements.length * 100)
          : 0,
    );
  }

  /// Уведомить слушателей об изменениях
  void _notifyListeners() {
    if (!_streamController.isClosed) {
      _streamController.add(List.unmodifiable(_localCache));
    }
  }

  /// Освободить ресурсы
  void dispose() {
    _streamController.close();
  }

  // =====================================================
  // Реализация методов из AchievementRepository интерфейса
  // =====================================================

  @override
  Future<Either<String, List<Achievement>>> getAllAchievements() {
    return getAchievements();
  }

  @override
  Future<Either<String, List<AchievementProgress>>> getUserAchievements(int userId) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, AchievementProgress>> updateUserAchievement({
    required int userId,
    required int achievementId,
    required int progress,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, List<UserAchievementStatus>>> getUserAchievementStatus(int userId) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, UserAchievementStatus>> setUserAchievementStatus({
    required int userId,
    required int achievementId,
    required AchievementStatus status,
    int? progress,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, AchievementProgress>> incrementUserAchievementProgress({
    required int userId,
    required int achievementId,
    int incrementBy = 1,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, List<Achievement>>> getUserUnlockedAchievements(int userId) {
    return Future.value(right(getWithFilter(AchievementFilter.unlocked)));
  }

  @override
  Future<Either<String, List<Achievement>>> getUserLockedAchievements(int userId) {
    return Future.value(right(getWithFilter(AchievementFilter.available)));
  }

  @override
  Future<Either<String, List<Achievement>>> getUserInProgressAchievements(int userId) {
    final inProgress = _localCache
        .where((a) => !a.isUnlocked && a.currentProgress > 0)
        .toList();
    return Future.value(right(inProgress));
  }

  @override
  Future<Either<String, AchievementProgress>> getAchievementProgress({
    required int userId,
    required int achievementId,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, void>> resetAchievementProgressWithParams({
    required int userId,
    required int achievementId,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, void>> resetAchievementProgress({
    required int userId,
    required int achievementId,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }

  @override
  Future<Either<String, void>> awardAchievementReward({
    required int userId,
    required int achievementId,
  }) {
    // Не используется в новой реализации
    return Future.value(const Left('Not implemented'));
  }
}

// ============================================================================
// Extension methods для статистики
// ============================================================================

extension AchievementStatsExtension on AchievementsRepositoryImpl {
  /// Получить статистику достижений
  AchievementStats getStats() {
    final total = achievements.length;
    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final totalPoints = achievements.fold<int>(0, (sum, a) => sum + a.points);
    final earnedPoints = achievements
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
    final categoryAchievements = achievements.where((a) => a.category == category).toList();
    final unlocked = categoryAchievements.where((a) => a.isUnlocked).length;

    return CategoryProgress(
      category: category,
      total: categoryAchievements.length,
      unlocked: unlocked,
      progressPercent: categoryAchievements.isNotEmpty
          ? (unlocked / categoryAchievements.length * 100)
          : 0,
    );
  }
}
