import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_category.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../wardrobe/presentation/providers/wardrobe_provider.dart';
import '../../data/models/achievement_dto.dart';
import '../../data/repositories/achievements_repository.dart';
import '../../data/repositories/achievements_repository_impl.dart';
import '../../data/services/achievements_api_service.dart';

/// Провайдер API сервиса достижений
final achievementsApiServiceProvider = Provider<AchievementsApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AchievementsApiService(apiClient);
});

/// Провайдер репозитория достижений (с API интеграцией)
final achievementsRepositoryProvider = Provider<AchievementsRepositoryImpl>((ref) {
  final apiService = ref.watch(achievementsApiServiceProvider);
  final repo = AchievementsRepositoryImpl(apiService);
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// Провайдер списка всех достижений
final allAchievementsProvider = Provider<List<Achievement>>((ref) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return repository.achievements;
});

/// Провайдер статистики достижений
final achievementsStatsProvider = Provider<AchievementStats>((ref) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return repository.getStats();
});

/// Провайдер достижений с фильтром
final filteredAchievementsProvider = Provider.family<List<Achievement>, AchievementFilter>((ref, filter) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return repository.getWithFilter(filter);
});

/// Провайдер достижений по категории
final achievementsByCategoryProvider = Provider.family<List<Achievement>, AchievementCategory>((ref, category) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return repository.getByCategory(category);
});

/// Провайдер прогресса по категории
final categoryProgressProvider = Provider.family<CategoryProgress, AchievementCategory>((ref, category) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return repository.getCategoryProgress(category);
});

/// Провайдер для отслеживания только что разблокированных достижений
final newlyUnlockedAchievementsProvider = StateProvider<List<Achievement>>((ref) => []);

/// Провайдер данных достижений пользователя из API
final userAchievementsDataProvider = FutureProvider<UserAchievementsData>((ref) async {
  final repository = ref.watch(achievementsRepositoryProvider);
  final result = await repository.getUserAchievementsData();
  return result.fold(
    (error) => throw Exception(error),
    (data) => data,
  );
});

/// State notifier для управления достижениями
class AchievementsNotifier extends StateNotifier<AchievementsState> {
  AchievementsNotifier(this._repository) : super(const AchievementsState()) {
    _subscription = _repository.achievementsStream.listen((achievements) {
      state = state.copyWith(achievements: achievements, isLoading: false);
    });
  }

  final AchievementsRepositoryImpl _repository;
  late final StreamSubscription<List<Achievement>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  /// Загрузить все достижения из API
  Future<void> loadAllAchievements() async {
    state = state.copyWith(isLoading: true);
    try {
      // Репозиторий автоматически загружает данные при инициализации
      // Здесь мы просто ждем обновления через stream
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Загрузить достижения пользователя из API
  Future<UserAchievementsData?> loadUserAchievements() async {
    try {
      final result = await _repository.getUserAchievementsData();
      return result.fold(
        (error) {
          debugPrint('Ошибка загрузки достижений пользователя: $error');
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      debugPrint('Ошибка загрузки достижений пользователя: $e');
      return null;
    }
  }

  /// Обновить прогресс достижения
  Future<Achievement?> updateAchievementProgress(String achievementId, int progress) async {
    return await _repository.updateProgress(achievementId, progress);
  }

  /// Увеличить прогресс достижения
  Future<Achievement?> incrementAchievementProgress(String achievementId, {int by = 1}) async {
    return await _repository.incrementProgress(achievementId, by: by);
  }

  /// Разблокировать достижение
  Future<void> unlockAchievement(String achievementId) async {
    await _repository.unlockAchievement(userId: 0, achievementId: int.tryParse(achievementId) ?? 0);
  }

  /// Сбросить прогресс достижения
  Future<void> resetAchievementProgress(String achievementId) async {
    await _repository.resetProgress(achievementId);
  }

  /// Получить достижение по ID
  Achievement? getAchievementById(String id) {
    return _repository.getById(id);
  }

  /// Получить статистику
  AchievementStats getStats() {
    return _repository.getStats();
  }

  /// Трекнуть событие для достижений
  /// Возвращает список только что разблокированных достижений
  Future<List<Achievement>> trackEvent({
    required String eventType,
    int value = 1,
  }) async {
    final result = await _repository.trackEvent(eventType: eventType, value: value);
    return result.fold(
      (error) {
        debugPrint('Ошибка трекинга события: $error');
        return [];
      },
      (achievements) => achievements,
    );
  }

  /// Обработать событие для трекинга достижений (локальная версия)
  /// Возвращает список только что разблокированных достижений
  Future<List<Achievement>> handleEvent(AchievementEventType type, {int value = 1}) async {
    final newlyUnlocked = <Achievement>[];

    // Маппинг событий на достижения
    final eventAchievementMap = _getAchievementsForEvent(type);

    for (final achievementId in eventAchievementMap) {
      final result = await _repository.incrementProgress(achievementId, by: value);
      if (result != null) {
        newlyUnlocked.add(result);
      }
    }

    return newlyUnlocked;
  }

  /// Получить ID достижений для типа события
  List<String> _getAchievementsForEvent(AchievementEventType type) {
    switch (type) {
      case AchievementEventType.addItem:
        return ['first_item', 'wardrobe_10', 'wardrobe_50', 'wardrobe_100', 'wardrobe_500', 'wardrobe_1000'];
      case AchievementEventType.useRecommendation:
        return ['first_recommendation', 'recommendation_10', 'recommendation_50', 'recommendation_100', 'recommendation_500'];
      case AchievementEventType.rateRecommendation:
        return ['first_rating', 'critic', 'rating_100'];
      case AchievementEventType.planOutfit:
        return ['first_plan', 'week_planner', 'month_planner'];
      case AchievementEventType.addFamilyMember:
        return ['family_first', 'family_large', 'family_wardrobe'];
      case AchievementEventType.useInColdWeather:
        return ['winter_warrior', 'weather_pro'];
      case AchievementEventType.useInHotWeather:
        return ['summer_lover', 'weather_pro'];
      case AchievementEventType.useInRain:
        return ['rainy_day', 'weather_pro'];
      case AchievementEventType.useInSnow:
        return ['snowy_day', 'weather_pro'];
      case AchievementEventType.morningUse:
        return ['early_bird'];
      case AchievementEventType.nightUse:
        return ['night_owl'];
      case AchievementEventType.highRating:
        return ['high_rated', 'positive', 'perfect_rating'];
      case AchievementEventType.lowRating:
        return ['honest'];
      case AchievementEventType.createOutfit:
        return ['trendsetter'];
      case AchievementEventType.dailyLogin:
        return ['first_day', 'first_week', 'first_month', 'first_year', 'daily_user', 'perfect_week', 'perfect_month'];
    }
  }
}

/// Типы событий для трекинга достижений
enum AchievementEventType {
  /// Добавление вещи в гардероб
  addItem,

  /// Использование рекомендации
  useRecommendation,

  /// Оценка рекомендации
  rateRecommendation,

  /// Планирование образа
  planOutfit,

  /// Добавление члена семьи
  addFamilyMember,

  /// Использование в холодную погоду
  useInColdWeather,

  /// Использование в жаркую погоду
  useInHotWeather,

  /// Использование в дождь
  useInRain,

  /// Использование в снег
  useInSnow,

  /// Утреннее использование
  morningUse,

  /// Ночное использование
  nightUse,

  /// Высокая оценка образа
  highRating,

  /// Низкая оценка образа
  lowRating,

  /// Создание образа
  createOutfit,

  /// Ежедневный вход
  dailyLogin,
}

/// Провайдер notifier
final achievementsNotifierProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return AchievementsNotifier(repository);
});

/// Состояние достижений
class AchievementsState {
  final List<Achievement> achievements;
  final bool isLoading;
  final String? error;

  const AchievementsState({
    this.achievements = const [],
    this.isLoading = false,
    this.error,
  });

  AchievementsState copyWith({
    List<Achievement>? achievements,
    bool? isLoading,
    String? error,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Получить разблокированные достижения
  List<Achievement> get unlockedAchievements =>
      achievements.where((a) => a.isUnlocked).toList();

  /// Получить заблокированные достижения
  List<Achievement> get lockedAchievements =>
      achievements.where((a) => !a.isUnlocked).toList();

  /// Получить достижения в процессе
  List<Achievement> get inProgressAchievements =>
      achievements.where((a) => !a.isUnlocked && a.currentProgress > 0).toList();

  /// Общий прогресс
  double get overallProgress {
    if (achievements.isEmpty) return 0;
    final unlocked = unlockedAchievements.length;
    return (unlocked / achievements.length) * 100;
  }
}
