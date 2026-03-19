import '../entities/outfit_recommendation.dart';
import '../repositories/i_recommendations_repository.dart';

/// Доменный сервис для работы с рекомендациями
class RecommendationsDomainService {
  final IRecommendationsRepository _repository;

  RecommendationsDomainService(this._repository);

  Future<List<OutfitRecommendation>> getUserRecommendations(
    String userId,
  ) async {
    return await _repository.getUserRecommendations(userId);
  }

  Future<OutfitRecommendation?> getRecommendationById(String id) async {
    return await _repository.getRecommendationById(id);
  }

  Future<void> saveRecommendation(OutfitRecommendation recommendation) async {
    return await _repository.saveRecommendation(recommendation);
  }

  Future<void> updateRecommendation(OutfitRecommendation recommendation) async {
    return await _repository.updateRecommendation(recommendation);
  }

  Future<void> deleteRecommendation(String id) async {
    return await _repository.deleteRecommendation(id);
  }

  Future<void> likeRecommendation(String id, bool liked) async {
    return await _repository.likeRecommendation(id, liked);
  }

  Future<void> saveRecommendationForLater(String id, bool saved) async {
    return await _repository.saveRecommendationForLater(id, saved);
  }

  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
    String weatherCondition,
    double temperature,
  ) async {
    return await _repository.getRecommendationsByWeather(
      weatherCondition,
      temperature,
    );
  }

  Future<List<OutfitRecommendation>> getTrendingRecommendations() async {
    return await _repository.getTrendingRecommendations();
  }

  Future<void> submitFeedback(String recommendationId, String feedback) async {
    return await _repository.submitFeedback(recommendationId, feedback);
  }

  Future<List<OutfitRecommendation>> getRecommendationsHistory(
    String userId,
  ) async {
    return await _repository.getRecommendationsHistory(userId);
  }

  Future<List<OutfitRecommendation>> getSavedRecommendations(
    String userId,
  ) async {
    return await _repository.getSavedRecommendations(userId);
  }
}
