import 'package:flutter/foundation.dart';

import '../../data/repositories/wardrobe_repository.dart';
import '../entities/wardrobe_entity.dart' as domain;
import '../entities/wardrobe_request_entities.dart';

class WardrobeDomainService {
  final WardrobeRepository _wardrobeRepository;

  WardrobeDomainService(this._wardrobeRepository);

  Stream<List<domain.WardrobeEntry>> watchWardrobe({required bool includeArchived}) {
    return _wardrobeRepository.watchAll(includeArchived: includeArchived);
  }

  Future<domain.WardrobeEntry?> getById(String id) async {
    return await _wardrobeRepository.getById(id);
  }

  Stream<domain.WardrobeEntry?> watchById(String id) {
    return _wardrobeRepository.watchById(id);
  }

  Future<void> toggleFavorite(domain.WardrobeEntry e) async {
    await _wardrobeRepository.setFavorite(e.id, !e.isFavorite);
  }

  Future<void> toggleArchived(domain.WardrobeEntry e) async {
    await _wardrobeRepository.setArchived(e.id, !e.isArchived);
  }

  Future<void> markWorn(domain.WardrobeEntry e) async {
    await _wardrobeRepository.incrementWearCount(e.id);
  }

  Future<void> syncFromServer() async {
    try {
      await _wardrobeRepository.syncFromServer();
    } catch (e) {
      debugPrint('Wardrobe sync error: $e');
      rethrow;
    }
  }

  Future<void> prefetchMissingImages({required int limit}) async {
    await _wardrobeRepository.prefetchMissingImages(limit: limit);
  }

  // CRUD операции для гардероба
  Future<domain.WardrobeEntry> createItem(WardrobeItemCreateRequest request) async {
    return await _wardrobeRepository.createItem(request);
  }

  Future<void> deleteItem(String id) async {
    await _wardrobeRepository.deleteById(id);
  }

  Future<List<domain.WardrobeEntry>> getItemsForRecommendation({
    String? category,
    String? season,
    String? weather,
  }) async {
    return await _wardrobeRepository.getForRecommendations(
      category: category,
      season: season,
      weather: weather,
    );
  }
}
