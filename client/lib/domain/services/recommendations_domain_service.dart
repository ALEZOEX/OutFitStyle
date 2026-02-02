import 'package:flutter/foundation.dart';

import '../../data/repositories/recommendations_repository.dart';
import '../../data/repositories/wardrobe_repository.dart';
import '../entities/recommendation_entity.dart';
import '../entities/wardrobe_entity.dart';

class RecommendationsDomainService {
  final RecommendationsRepository _recommendationsRepository;
  final WardrobeRepository _wardrobeRepository;

  RecommendationsDomainService(
    this._recommendationsRepository,
    this._wardrobeRepository,
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
  Future<RecommendationRow> generateRecommendation({required String occasion}) async {
    // В реальной реализации вызываем API для генерации рекомендации
    // Здесь временная реализация
    final now = DateTime.now();
    return await _recommendationsRepository.createLocal(
      id: 'rec_${now.millisecondsSinceEpoch}',
      outfitDataJson: '{"occasion": "$occasion"}',
      weatherDataJson: '{}',
      isFavorite: false,
      imageUrl: null,
      localImagePath: null,
    );
  }

  Future<RecommendationRow> generateRecommendationWithItem({
    required WardrobeEntry item,
    required String occasion,
    bool includeWeather = true,
  }) async {
    // В реальной реализации вызываем API для генерации рекомендации с учетом выбранного элемента
    // Здесь временная реализация
    final now = DateTime.now();
    return await _recommendationsRepository.createLocal(
      id: 'rec_with_item_${now.millisecondsSinceEpoch}',
      outfitDataJson: '{"occasion": "$occasion", "itemId": "${item.id}"}',
      weatherDataJson: includeWeather ? '{}' : '{}',
      isFavorite: false,
      imageUrl: null,
      localImagePath: null,
    );
  }

  Future<RecommendationRow> createLocal({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
  }) async {
    final now = DateTime.now();
    return await _recommendationsRepository.createLocal(
      id: 'local_${now.millisecondsSinceEpoch}',
      outfitDataJson: _encodeJson(outfitData),
      weatherDataJson: _encodeJson(weatherData),
      isFavorite: false,
      imageUrl: null,
      localImagePath: null,
    );
  }

  Future<RecommendationRow> saveLocalOutfit({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
    required bool favorite,
  }) async {
    final now = DateTime.now();
    return await _recommendationsRepository.createLocal(
      id: 'saved_${now.millisecondsSinceEpoch}',
      outfitDataJson: _encodeJson(outfitData),
      weatherDataJson: _encodeJson(weatherData),
      isFavorite: favorite,
      imageUrl: null,
      localImagePath: null,
    );
  }

  String _encodeJson(Map<String, dynamic> data) {
    return data.toString(); // Временная реализация, в реальности использовать json.encode
  }
}