import 'package:flutter/foundation.dart';

import '../../data/repositories/wardrobe_repository.dart';
import '../entities/wardrobe_entity.dart';
import '../entities/wardrobe_request_entities.dart';

class WardrobeDomainService {
  final WardrobeRepository _wardrobeRepository;

  WardrobeDomainService(this._wardrobeRepository);

  Stream<List<WardrobeEntry>> watchWardrobe({required bool includeArchived}) {
    return _wardrobeRepository.watchAll(includeArchived: includeArchived);
  }

  Future<WardrobeEntry?> getById(String id) async {
    return await _wardrobeRepository.getById(id);
  }

  Stream<WardrobeEntry?> watchById(String id) {
    return _wardrobeRepository.watchById(id);
  }

  Future<void> toggleFavorite(WardrobeEntry e) async {
    await _wardrobeRepository.setFavorite(e.id, !e.isFavorite);
  }

  Future<void> toggleArchived(WardrobeEntry e) async {
    await _wardrobeRepository.setArchived(e.id, !e.isArchived);
  }

  Future<void> markWorn(WardrobeEntry e) async {
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
  Future<WardrobeEntry> createItem(WardrobeItemCreateRequest request) async {
    return await _wardrobeRepository.insertOne(
      id: request.name.toLowerCase().replaceAll(' ', '_'),
      name: request.name,
      category: request.category,
      subcategory: request.subcategory,
      style: request.style,
      iconEmoji: request.iconEmoji,
      imageUrl: request.imageUrl,
      blurHash: request.blurHash,
      minTemp: request.minTemp,
      maxTemp: request.maxTemp,
      warmthLevel: request.warmthLevel,
      rainOk: request.rainOk,
      snowOk: request.snowOk,
      windOk: request.windOk,
      usage: request.usage,
      materials: request.materials,
      isFavorite: request.isFavorite,
      isArchived: request.isArchived,
      season: request.season,
      gender: request.gender,
      fit: request.fit,
      pattern: request.pattern,
      localImagePath: request.localImagePath,
    );
  }

  Future<void> updateItem(String id, WardrobeItemUpdateRequest request) async {
    await _wardrobeRepository.updateOne(
      id: id,
      name: request.name,
      category: request.category,
      subcategory: request.subcategory,
      style: request.style,
      iconEmoji: request.iconEmoji,
      imageUrl: request.imageUrl,
      blurHash: request.blurHash,
      minTemp: request.minTemp,
      maxTemp: request.maxTemp,
      warmthLevel: request.warmthLevel,
      rainOk: request.rainOk,
      snowOk: request.snowOk,
      windOk: request.windOk,
      usage: request.usage,
      materials: request.materials,
      isFavorite: request.isFavorite,
      isArchived: request.isArchived,
      season: request.season,
      gender: request.gender,
      fit: request.fit,
      pattern: request.pattern,
      localImagePath: request.localImagePath,
    );
  }

  Future<void> deleteItem(String id) async {
    await _wardrobeRepository.deleteById(id);
  }

  Future<List<WardrobeEntry>> getItemsForRecommendation({
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
