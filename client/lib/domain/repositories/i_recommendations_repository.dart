import 'dart:async';
import '../entities/outfit_recommendation.dart';

abstract class IRecommendationsRepository {
  // Local data sources
  Stream<List<OutfitRecommendation>> watchHistory({int limit = 10});
  Stream<OutfitRecommendation?> watchTodayLatest();
  Future<List<OutfitRecommendation>> getRecommendationsByUser(String userId, {DateTime? fromDate, DateTime? toDate});
  Future<OutfitRecommendation?> getRecommendationById(String id);
  Future<OutfitRecommendation> saveRecommendation(OutfitRecommendation recommendation);
  Future<OutfitRecommendation> updateRecommendation(OutfitRecommendation recommendation);
  Future<void> deleteRecommendation(String id);
  Future<List<OutfitRecommendation>> getRecommendationsHistory(String userId);
  Future<OutfitRecommendation> generateRecommendation({
    required List<String> excludedItems,
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  });
  Future<OutfitRecommendation> getMatchingItemsForRecommendation({
    required String occasion,
    required double temperature,
    required String userId,
    required String weatherCondition,
  });

  // Remote data sources
  Future<List<OutfitRecommendation>> getRecommendationsByUserFromRemote(String userId, {DateTime? fromDate, DateTime? toDate});
  Future<OutfitRecommendation> getRecommendationByIdFromRemote(String id);
  Future<OutfitRecommendation> createRecommendationToRemote(OutfitRecommendation recommendation);
  Future<OutfitRecommendation> updateRecommendationToRemote(OutfitRecommendation recommendation);
  Future<void> deleteRecommendationFromRemote(String id);
  Future<List<OutfitRecommendation>> getRecommendationsHistoryFromRemote(String userId);
  Future<OutfitRecommendation> generateRecommendationFromRemote({
    required List<String> excludedItems,
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  });
  Future<OutfitRecommendation> getMatchingItemsForRecommendationFromRemote({
    required String occasion,
    required double temperature,
    required String userId,
    required String weatherCondition,
  });

  // Sync methods
  Future<void> syncRecommendations();
  Future<void> markAsSynced(String id, String remoteId);
}