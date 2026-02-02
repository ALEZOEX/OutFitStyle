import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../repositories/recommendations_repository.dart';

final recommendationsServiceProvider = Provider<RecommendationsService>((ref) {
  final repository = ref.watch(recommendationsRepositoryProvider);
  return RecommendationsService(repository);
});

class RecommendationsService {
  final RecommendationsRepository _repository;

  RecommendationsService(this._repository);

  Stream<List<RecommendationRow>> watchHistory({int limit = 50}) {
    return _repository.watchHistory(limit: limit);
  }

  Stream<RecommendationRow?> watchById(String id) {
    return _repository.watchById(id);
  }

  Stream<List<TimelineDay>> watchTimeline({int limit = 7}) {
    return _repository.watchTimeline(limit: limit);
  }

  Future<void> syncFromServer() async {
    await _repository.syncFromServer();
  }

  Future<void> toggleFavorite(RecommendationRow r) async {
    await _repository.toggleFavorite(r);
  }

  Future<String> createLocal({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
  }) async {
    return await _repository.createLocal(
      outfitData: outfitData,
      weatherData: weatherData,
    );
  }

  Future<RecommendationRow> generateRecommendation({required String occasion}) async {
    return await _repository.generateRecommendation(occasion: occasion);
  }

  Future<RecommendationRow> generateRecommendationWithItem({
    required WardrobeEntry item,
    required String occasion,
    bool includeWeather = true,
  }) async {
    return await _repository.generateRecommendationWithItem(
      item: item,
      occasion: occasion,
      includeWeather: includeWeather,
    );
  }

  Stream<List<TimelineDay>> watchTimeline({int limit = 7}) {
    return _repository.watchTimeline(limit: limit);
  }

  Stream<RecommendationRow?> watchTodayLatest() {
    return _repository.watchTodayLatest();
  }

  Future<RecommendationRow> saveLocalOutfit({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
    required bool favorite,
  }) async {
    return await _repository.saveLocalOutfit(
      outfitData: outfitData,
      weatherData: weatherData,
      favorite: favorite,
    );
  }

  Future<RecommendationRow?> getById(String id) async {
    return await _repository.getById(id);
  }

  Future<void> prefetchMissingImages({int limit = 30}) async {
    await _repository.prefetchMissingImages(limit: limit);
  }
}