import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/entities/recommendation.dart';
import '../../../../domain/entities/user_preference.dart';

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
  RecommendationStateNotifier() : super(const RecommendationState());

  /// Получить рекомендации для пользователя
  Future<void> fetchRecommendations({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual API call when backend is ready
      // Simulating API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        isLoading: false,
        recommendations: const AsyncValue.data([]),
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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 200));
      
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
    }
  }

  /// Сохранить рекомендацию
  Future<void> saveRecommendation(String recommendationId) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 200));
      
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
    }
  }

  /// Удалить рекомендацию из сохранённых
  Future<void> unsaveRecommendation(String recommendationId) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 200));
      
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
    }
  }

  /// Переключить сохранение рекомендации
  Future<void> toggleSave(String recommendationId) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 200));
      
      final currentRecommendations = state.recommendations.value ?? [];
      final updatedRecommendations = currentRecommendations.map((rec) {
        if (rec.id.toString() == recommendationId) {
          return rec.copyWith(isSaved: !(rec.isSaved));
        }
        return rec;
      }).toList();
      
      state = state.copyWith(
        recommendations: AsyncValue.data(updatedRecommendations),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Обновить предпочтения пользователя
  Future<void> updateUserPreferences({
    required String userId,
    required UserPreference preferences,
  }) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 200));
      
      state = state.copyWith(preferences: preferences);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Загрузить историю рекомендаций
  Future<void> loadRecommendationHistory({required String userId}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        isLoading: false,
        historyRecommendations: [],
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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        isLoading: false,
        savedRecommendations: [],
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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        isLoading: false,
        preferences: const UserPreference(),
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
  (ref) => RecommendationStateNotifier(),
);
