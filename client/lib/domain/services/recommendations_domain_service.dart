import 'package:outfitstyle_client/domain/entities/outfit_recommendation.dart';
import 'package:outfitstyle_client/domain/repositories/i_recommendations_repository.dart';

class RecommendationsDomainService {
  final IRecommendationsRepository _repository;

  RecommendationsDomainService(this._repository);

  Stream<List<OutfitRecommendation>> watchHistory({int limit = 50}) {
    return _repository.watchHistory(limit: limit);
  }

  Stream<OutfitRecommendation?> watchTodayLatest() {
    return _repository.watchTodayLatest();
  }

  Future<List<OutfitRecommendation>> getRecommendationsByUser(String userId, {DateTime? fromDate, DateTime? toDate}) async {
    return await _repository.getRecommendationsByUser(userId, fromDate: fromDate, toDate: toDate);
  }

  Future<OutfitRecommendation?> getRecommendationById(String id) async {
    return await _repository.getRecommendationById(id);
  }

  Future<OutfitRecommendation> saveRecommendation(OutfitRecommendation recommendation) async {
    return await _repository.saveRecommendation(recommendation);
  }

  Future<OutfitRecommendation> updateRecommendation(OutfitRecommendation recommendation) async {
    return await _repository.updateRecommendation(recommendation);
  }

  Future<void> deleteRecommendation(String id) async {
    return await _repository.deleteRecommendation(id);
  }

  Future<void> rateRecommendation(String id, double rating) async {
    return await _repository.rateRecommendation(id, rating);
  }

  Future<List<OutfitRecommendation>> getRecommendationsHistory(String userId) async {
    return await _repository.getRecommendationsHistory(userId);
  }

  Future<OutfitRecommendation> generateRecommendation({
    required String occasion,
    required double temperature,
    required String userId,
    required String weatherCondition,
  }) async {
    // This would typically call a remote service to generate a recommendation
    // For now, we'll create a basic recommendation
    return await _repository.generateRecommendation(
      excludedItems: [],
      latitude: 0.0, // Placeholder - would come from user location
      longitude: 0.0, // Placeholder - would come from user location
      occasion: occasion,
      preferredStyles: [], // Would come from user preferences
      userId: userId,
    );
  }

  Future<OutfitRecommendation> getMatchingItemsForRecommendation({
    required String occasion,
    required double temperature,
    required String weatherCondition,
    required String userId,
  }) async {
    return await _repository.getMatchingItemsForRecommendation(
      occasion: occasion,
      temperature: temperature,
      weatherCondition: weatherCondition,
      userId: userId,
    );
  }

  // Business logic methods
  Future<List<OutfitRecommendation>> getRecentRecommendations() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return await getRecommendationsByUser('current_user', fromDate: startOfDay, toDate: now);
  }

  Future<List<OutfitRecommendation>> getTopRatedRecommendations(int count) async {
    final allRecommendations = await getRecommendationsHistory('current_user');
    // Sort by confidence score or rating and return top 'count' items
    allRecommendations.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
    return allRecommendations.take(count).toList();
  }

  Future<List<OutfitRecommendation>> getRecommendationsForOutfitPlanning({
    required String occasion,
    required DateTime date,
    required String location,
  }) async {
    // This would typically call a remote service to generate recommendations for a specific occasion
    // For now, we'll return an empty list
    return [];
  }

  Future<List<OutfitRecommendation>> getRecommendationsByWeatherCondition(String weatherCondition) async {
    // This would typically filter recommendations by weather condition
    // For now, we'll return an empty list
    return [];
  }

  Future<List<OutfitRecommendation>> getRecommendationsBySeason(String season) async {
    // This would typically filter recommendations by season
    // For now, we'll return an empty list
    return [];
  }
}