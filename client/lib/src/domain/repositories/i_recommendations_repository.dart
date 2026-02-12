import '../entities/outfit_recommendation.dart';

abstract class IRecommendationsRepository {
  Future<List<OutfitRecommendation>> getUserRecommendations(String userId);
  Future<OutfitRecommendation?> getRecommendationById(String id);
  Future<void> saveRecommendation(OutfitRecommendation recommendation);
  Future<void> updateRecommendation(OutfitRecommendation recommendation);
  Future<void> deleteRecommendation(String id);
  Future<void> likeRecommendation(String id, bool liked);
  Future<void> saveRecommendationForLater(String id, bool saved);
  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
      String weatherCondition, double temperature);
  Future<List<OutfitRecommendation>> getTrendingRecommendations();
  Future<void> submitFeedback(String recommendationId, String feedback);
  Future<List<OutfitRecommendation>> getRecommendationsHistory(String userId);
  Future<List<OutfitRecommendation>> getSavedRecommendations(String userId);
}