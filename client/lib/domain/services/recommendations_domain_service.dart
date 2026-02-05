import 'package:flutter/foundation.dart';

import '../../data/repositories/recommendations_repository.dart';
import '../entities/recommendation_entity.dart';
import '../entities/wardrobe_entity.dart' as domain;

class RecommendationsDomainService {
  final RecommendationsRepository _recommendationsRepository;

  RecommendationsDomainService(
    this._recommendationsRepository,
  );

  // Методы для работы с рекомендациями
  Stream<List<RecommendationRow>> watchHistory({required int limit}) {
    return _recommendationsRepository.watchHistory(limit: limit);
  }

  Future<RecommendationRow?> getById(String id) async {
    return await _recommendationsRepository.getById(id);
  }

  Stream<RecommendationRow?> watchById(String id) {
    return _recommendationsRepository.watchById(id);
  }

  Future<void> toggleFavorite(RecommendationRow r) async {
    await _recommendationsRepository.setFavorite(r.id, !r.isFavorite);
  }

  Future<void> syncFromServer() async {
    try {
      await _recommendationsRepository.syncFromServer();
    } catch (e) {
      debugPrint('Recommendations sync error: $e');
      rethrow;
    }
  }

  Future<void> prefetchMissingImages({required int limit}) async {
    await _recommendationsRepository.prefetchMissingImages(limit: limit);
  }

  // Методы для генерации рекомендаций
  Future<RecommendationRow> generateRecommendation(
      {required String occasion}) async {
    // В реальной реализации вызываем API для генерации рекомендации
    // Здесь временная реализация
    return await _recommendationsRepository.createLocal(
      outfitData: {"occasion": occasion},
      weatherData: {},
    );
  }

  Future<RecommendationRow> generateRecommendationWithItem({
    required domain.WardrobeEntry item,
    required String occasion,
    bool includeWeather = true,
  }) async {
    // В реальной реализации вызываем API для генерации рекомендации с учетом выбранного элемента
    // Здесь временная реализация
    return await _recommendationsRepository.generateRecommendationWithItem(
      item: item,
      occasion: occasion,
      includeWeather: includeWeather,
    );
  }

  Future<RecommendationRow> createLocal({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
  }) async {
    return await _recommendationsRepository.createLocal(
      outfitData: outfitData,
      weatherData: weatherData,
    );
  }

  Future<RecommendationRow> saveLocalOutfit({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
    required bool favorite,
  }) async {
    final recommendation = await _recommendationsRepository.createLocal(
      outfitData: outfitData,
      weatherData: weatherData,
    );

    // Update favorite status if needed
    if (favorite != recommendation.isFavorite) {
      await _recommendationsRepository.toggleFavorite(recommendation);
    }

    return recommendation;
  }
}
