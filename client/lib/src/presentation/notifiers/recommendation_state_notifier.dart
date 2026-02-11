import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/domain/entities/recommendation.dart';
import 'package:outfitstyle_client/src/domain/entities/user_preference.dart';
import 'package:outfitstyle_client/src/domain/usecases/get_recommendations_usecase.dart';
import '../providers/repository_providers.dart';

// Provider для usecase получения рекомендаций
final getRecommendationsUseCaseProvider =
    Provider<GetRecommendationsUseCase>((ref) {
  return GetRecommendationsUseCase(ref.read(recommendationRepositoryProvider));
});

// AsyncNotifier для управления состоянием рекомендаций
final recommendationStateNotifierProvider =
    StateNotifierProvider<RecommendationStateNotifier, RecommendationState>(
  (ref) => RecommendationStateNotifier(
    ref.read(getRecommendationsUseCaseProvider),
  ),
);

class RecommendationState {
  final List<Recommendation> recommendations;
  final List<Recommendation> savedRecommendations;
  final List<Recommendation> historyRecommendations;
  final UserPreference userPreferences;
  final bool isLoading;
  final String? errorMessage;

  RecommendationState({
    this.recommendations = const [],
    this.savedRecommendations = const [],
    this.historyRecommendations = const [],
    this.userPreferences = const UserPreference(),
    this.isLoading = false,
    this.errorMessage,
  });

  RecommendationState copyWith({
    List<Recommendation>? recommendations,
    List<Recommendation>? savedRecommendations,
    List<Recommendation>? historyRecommendations,
    UserPreference? userPreferences,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      savedRecommendations: savedRecommendations ?? this.savedRecommendations,
      historyRecommendations:
          historyRecommendations ?? this.historyRecommendations,
      userPreferences: userPreferences ?? this.userPreferences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RecommendationStateNotifier extends StateNotifier<RecommendationState> {
  final GetRecommendationsUseCase _getRecommendationsUseCase;

  RecommendationStateNotifier(this._getRecommendationsUseCase)
      : super(RecommendationState());

  Future<void> fetchRecommendations({
    String? userId,
    double? latitude,
    double? longitude,
    String? occasion,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _getRecommendationsUseCase(
      userId: userId ?? '',
      latitude: latitude,
      longitude: longitude,
      occasion: occasion,
    );

    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        errorMessage: error,
      ),
      (recommendations) => state = state.copyWith(
        recommendations: recommendations,
        isLoading: false,
      ),
    );
  }

  void toggleLike(String recommendationId) {
    final updatedRecommendations = state.recommendations.map((recommendation) {
      if (recommendation.id?.toString() == recommendationId) {
        return recommendation.copyWith(
          isLiked: !(recommendation.isLiked ?? false),
        );
      }
      return recommendation;
    }).toList();

    state = state.copyWith(recommendations: updatedRecommendations);
  }

  void toggleSave(String recommendationId) {
    final updatedRecommendations = state.recommendations.map((recommendation) {
      if (recommendation.id?.toString() == recommendationId) {
        return recommendation.copyWith(
          isSaved: !recommendation.isSaved,
        );
      }
      return recommendation;
    }).toList();

    state = state.copyWith(recommendations: updatedRecommendations);
  }

  Future<void> loadRecommendationHistory({required String userId}) async {
    // For now, just set empty list - implement actual loading later
    state = state.copyWith(historyRecommendations: []);
  }

  Future<void> loadSavedRecommendations({required String userId}) async {
    // For now, just set empty list - implement actual loading later
    state = state.copyWith(savedRecommendations: []);
  }

  Future<void> loadUserPreferences({required String userId}) async {
    // For now, just set default preferences - implement actual loading later
    state = state.copyWith(userPreferences: UserPreference());
  }

  Future<void> updateUserPreferences(
      {required String userId, required UserPreference preferences}) async {
    // Update the state with new preferences
    state = state.copyWith(userPreferences: preferences);
  }
}
