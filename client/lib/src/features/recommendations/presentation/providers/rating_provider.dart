import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/providers/session_provider.dart';
import '../../../../domain/entities/outfit_rating.dart';
import '../../data/services/rating_api_service.dart';

/// Провайдер API сервиса рейтинга
final ratingApiServiceProvider = Provider<RatingApiService>((ref) {
  final client = ref.watch(apiClientProvider);
  return RatingApiService(client: client);
});

/// Состояние провайдера рейтинга
class RatingState {
  final Map<String, RecommendationQuality> qualityCache;
  final Map<String, OutfitRating> userRatingsCache;
  final UserRatingStats? userStats;
  final bool isLoading;
  final String? error;

  const RatingState({
    this.qualityCache = const {},
    this.userRatingsCache = const {},
    this.userStats,
    this.isLoading = false,
    this.error,
  });

  RatingState copyWith({
    Map<String, RecommendationQuality>? qualityCache,
    Map<String, OutfitRating>? userRatingsCache,
    UserRatingStats? userStats,
    bool? isLoading,
    String? error,
  }) {
    return RatingState(
      qualityCache: qualityCache ?? this.qualityCache,
      userRatingsCache: userRatingsCache ?? this.userRatingsCache,
      userStats: userStats ?? this.userStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Нотификер провайдера для управления состоянием рейтинга
class RatingNotifier extends StateNotifier<RatingState> {
  final RatingApiService _apiService;

  RatingNotifier(this._apiService) : super(const RatingState());

  /// Оценить рекомендацию
  Future<OutfitRating> rateOutfit({
    required String recommendationId,
    required int rating,
    List<int>? outfitItems,
    String? feedback,
    ThermalFeedback? thermalFeedback,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _apiService.rateOutfit(
        recommendationId: recommendationId,
        rating: rating,
        outfitItems: outfitItems,
        feedback: feedback,
        thermalFeedback: thermalFeedback,
      );

      // Обновляем кэш оценки пользователя
      state = state.copyWith(
        userRatingsCache: {...state.userRatingsCache, recommendationId: result},
        isLoading: false,
      );

      // Обновляем кэш качества (инвалидируем, чтобы перезагрузить)
      state.qualityCache.remove(recommendationId);

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Получить статистику качества рекомендации
  Future<RecommendationQuality> getQuality(String recommendationId) async {
    // Проверяем кэш
    if (state.qualityCache.containsKey(recommendationId)) {
      return state.qualityCache[recommendationId]!;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final quality = await _apiService.getQuality(recommendationId);

      // Обновляем кэш
      state = state.copyWith(
        qualityCache: {...state.qualityCache, recommendationId: quality},
        isLoading: false,
      );

      return quality;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Получить оценку пользователя
  Future<OutfitRating?> getUserRating(String recommendationId) async {
    // Проверяем кэш
    if (state.userRatingsCache.containsKey(recommendationId)) {
      return state.userRatingsCache[recommendationId];
    }

    try {
      final rating = await _apiService.getUserRating(recommendationId);

      if (rating != null) {
        state = state.copyWith(
          userRatingsCache: {
            ...state.userRatingsCache,
            recommendationId: rating,
          },
        );
      }

      return rating;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Загрузить статистику пользователя
  Future<UserRatingStats?> loadUserStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _apiService.getUserStats();
      state = state.copyWith(userStats: stats, isLoading: false);
      return stats;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Инвалидировать кэш качества для рекомендации
  void invalidateQualityCache(String recommendationId) {
    state.qualityCache.remove(recommendationId);
  }

  /// Очистить весь кэш
  void clearCache() {
    state = const RatingState();
  }
}

/// Провайдер нотификера рейтинга
final ratingNotifierProvider =
    StateNotifierProvider<RatingNotifier, RatingState>((ref) {
      final apiService = ref.watch(ratingApiServiceProvider);
      return RatingNotifier(apiService);
    });

/// Провайдер для получения качества конкретной рекомендации
final recommendationQualityProvider =
    FutureProvider.family<RecommendationQuality, String>((
      ref,
      recommendationId,
    ) async {
      final notifier = ref.watch(ratingNotifierProvider.notifier);
      return notifier.getQuality(recommendationId);
    });

/// Провайдер для получения оценки пользователя для конкретной рекомендации
final userRatingProvider = FutureProvider.family<OutfitRating?, String>((
  ref,
  recommendationId,
) async {
  final notifier = ref.watch(ratingNotifierProvider.notifier);
  return notifier.getUserRating(recommendationId);
});

/// Провайдер статистики пользователя
final userRatingStatsProvider = FutureProvider<UserRatingStats?>((ref) async {
  final notifier = ref.watch(ratingNotifierProvider.notifier);
  return notifier.loadUserStats();
});
