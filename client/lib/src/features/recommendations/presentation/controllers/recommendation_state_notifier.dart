import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/entities/recommendation.dart';
import '../../../../domain/entities/user_preference.dart';
import '../../../../data/repositories/recommendations_repository.dart';
import '../../../../data/repositories/profile_repository.dart';

part 'recommendation_state_notifier.freezed.dart';

/// Состояние рекомендательной системы
@freezed
class RecommendationState with _$RecommendationState {
  const factory RecommendationState({
    @Default(AsyncValue.loading())
    AsyncValue<List<Recommendation>> recommendations,
    @Default([])
    List<Recommendation> historyRecommendations,
    @Default([])
    List<Recommendation> savedRecommendations,
    @Default(UserPreference())
    UserPreference preferences,
    @Default(false) bool isLoading,
    @Default(false) bool isRefreshing,
    String? error,
  }) = _RecommendationState;

  const RecommendationState._();

  /// Геттер для сообщения об ошибке (для совместимости с UI)
  String? get errorMessage => error;
}

/// Нотификатор состояния рекомендаций
class RecommendationStateNotifier extends StateNotifier<RecommendationState> {
  final RecommendationsRepository _recommendationsRepository;
  final ProfileRepository _profileRepository;

  RecommendationStateNotifier({
    required RecommendationsRepository recommendationsRepository,
    required ProfileRepository profileRepository,
  })  : _recommendationsRepository = recommendationsRepository,
        _profileRepository = profileRepository,
        super(const RecommendationState());

  /// Получить рекомендации для пользователя
  Future<void> fetchRecommendations({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final recommendations = await _recommendationsRepository.getUserRecommendations(userId);
      final entityRecommendations = recommendations
          .map((r) => Recommendation(
                id: r.id != null ? int.tryParse(r.id!) : null,
                title: r.title,
                description: r.description,
                imageUrl: r.imageUrl,
                outfit: null,
                isFavorite: false,
                isSaved: false,
              ))
          .toList();

      state = state.copyWith(
        isLoading: false,
        recommendations: AsyncValue.data(entityRecommendations),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        recommendations: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  /// Переключить лайк рекомендации
  Future<void> toggleLike(String recommendationId) async {
    try {
      await _recommendationsRepository.likeRecommendation(recommendationId, true);

      final currentRecommendations = state.recommendations.value ?? [];
      final updatedRecommendations = currentRecommendations.map((rec) {
        if (rec.id.toString() == recommendationId) {
          return rec.copyWith(isFavorite: !(rec.isFavorite));
        }
        return rec;
      }).toList();

      state = state.copyWith(
        recommendations: AsyncValue.data(updatedRecommendations),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Сохранить рекомендацию
  Future<void> saveRecommendation(String recommendationId) async {
    try {
      await _recommendationsRepository.saveRecommendationForLater(recommendationId, true);

      final currentRecommendations = state.recommendations.value ?? [];
      final updatedRecommendations = currentRecommendations.map((rec) {
        if (rec.id.toString() == recommendationId) {
          return rec.copyWith(isSaved: true);
        }
        return rec;
      }).toList();

      state = state.copyWith(
        recommendations: AsyncValue.data(updatedRecommendations),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Удалить рекомендацию из сохранённых
  Future<void> unsaveRecommendation(String recommendationId) async {
    try {
      await _recommendationsRepository.saveRecommendationForLater(recommendationId, false);

      final currentRecommendations = state.recommendations.value ?? [];
      final updatedRecommendations = currentRecommendations.map((rec) {
        if (rec.id.toString() == recommendationId) {
          return rec.copyWith(isSaved: false);
        }
        return rec;
      }).toList();

      state = state.copyWith(
        recommendations: AsyncValue.data(updatedRecommendations),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Переключить сохранение рекомендации
  Future<void> toggleSave(String recommendationId) async {
    try {
      final isCurrentlySaved = state.recommendations.value
              ?.firstWhere((rec) => rec.id.toString() == recommendationId)
              .isSaved ??
          false;
      await _recommendationsRepository.saveRecommendationForLater(
          recommendationId, !isCurrentlySaved);

      final currentRecommendations = state.recommendations.value ?? [];
      final updatedRecommendations = currentRecommendations.map((rec) {
        if (rec.id.toString() == recommendationId) {
          return rec.copyWith(isSaved: !isCurrentlySaved);
        }
        return rec;
      }).toList();

      state = state.copyWith(
        recommendations: AsyncValue.data(updatedRecommendations),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Обновить предпочтения пользователя
  Future<void> updateUserPreferences({
    required String userId,
    required UserPreference preferences,
  }) async {
    try {
      await _profileRepository.updatePreferences(preferences.toJson());
      state = state.copyWith(preferences: preferences);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Загрузить историю рекомендаций
  Future<void> loadRecommendationHistory({required String userId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = await _recommendationsRepository.getRecommendationsHistory(userId);
      final entityRecommendations = history
          .map((r) => Recommendation(
                id: r.id != null ? int.tryParse(r.id!) : null,
                title: r.title,
                description: r.description,
                imageUrl: r.imageUrl,
                outfit: null,
                isFavorite: false,
                isSaved: false,
              ))
          .toList();

      state = state.copyWith(
        isLoading: false,
        historyRecommendations: entityRecommendations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Загрузить сохранённые рекомендации
  Future<void> loadSavedRecommendations({required String userId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final saved = await _recommendationsRepository.getSavedRecommendations(userId);
      final entityRecommendations = saved
          .map((r) => Recommendation(
                id: r.id != null ? int.tryParse(r.id!) : null,
                title: r.title,
                description: r.description,
                imageUrl: r.imageUrl,
                outfit: null,
                isFavorite: false,
                isSaved: true,
              ))
          .toList();

      state = state.copyWith(
        isLoading: false,
        savedRecommendations: entityRecommendations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Загрузить предпочтения пользователя
  Future<void> loadUserPreferences({required String userId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _profileRepository.getMe();
      final preferencesData = profile['preferences'] as Map<String, dynamic>?;
      final preferences = preferencesData != null
          ? UserPreference.fromJson(preferencesData)
          : const UserPreference();

      state = state.copyWith(
        isLoading: false,
        preferences: preferences,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Обновить рекомендацию (для фильтрации/обновления)
  void updateRecommendations(List<Recommendation> recommendations) {
    state = state.copyWith(
      recommendations: AsyncValue.data(recommendations),
      isLoading: false,
      error: null,
    );
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Установить состояние загрузки
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Установить состояние обновления
  void setRefreshing(bool refreshing) {
    state = state.copyWith(isRefreshing: refreshing);
  }
}

/// Provider для нотификатора состояния рекомендаций
final recommendationStateNotifierProvider =
    StateNotifierProvider<RecommendationStateNotifier, RecommendationState>(
  (ref) {
    throw UnimplementedError('Используйте recommendationStateNotifierProvider.override');
  },
);
