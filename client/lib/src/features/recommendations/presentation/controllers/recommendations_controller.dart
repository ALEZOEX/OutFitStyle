import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/recommendations_state.dart';
import '../../../../domain/services/recommendations_domain_service.dart';

/// Контроллер рекомендаций
class RecommendationsController extends StateNotifier<RecommendationsState> {
  final RecommendationsDomainService _domainService;

  RecommendationsController(this._domainService)
    : super(const RecommendationsState());

  /// Получение рекомендаций для пользователя
  Future<void> loadRecommendations(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final recommendations = await _domainService.getUserRecommendations(
        userId,
      );
      state = state.copyWith(
        isLoading: false,
        recommendations: recommendations.map((r) => r.toJson()).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Лайк рекомендации
  Future<void> likeRecommendation(String id, bool liked) async {
    try {
      await _domainService.likeRecommendation(id, liked);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
