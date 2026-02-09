import 'package:outfitstyle_client/domain/entities/wardrobe_item.dart';
import 'package:outfitstyle_client/domain/repositories/i_wardrobe_repository.dart';

class WardrobeDomainService {
  final IWardrobeRepository _repository;

  WardrobeDomainService(this._repository);

  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false}) {
    return _repository.watchWardrobe(includeArchived: includeArchived);
  }

  Stream<WardrobeItem?> watchById(String id) {
    return _repository.watchById(id);
  }

  Future<List<WardrobeItem>> getAllWardrobeItems({String? userId}) async {
    return await _repository.getAllWardrobeItems(userId: userId);
  }

  Future<WardrobeItem?> getWardrobeItemById(String id) async {
    return await _repository.getWardrobeItemById(id);
  }

  Future<WardrobeItem> addWardrobeItem(WardrobeItem item) async {
    return await _repository.addWardrobeItem(item);
  }

  Future<WardrobeItem> updateWardrobeItem(WardrobeItem item) async {
    return await _repository.updateWardrobeItem(item);
  }

  Future<void> deleteWardrobeItem(String id) async {
    return await _repository.deleteWardrobeItem(id);
  }

  Future<List<WardrobeItem>> filterWardrobeItems({
    String? category,
    String? subcategory,
    String? color,
    String? brand,
    String? name,
    bool? isFavorite,
    bool? isArchived,
    String? userId,
    String? season,
    String? style,
    List<String>? occasions,
  }) async {
    return await _repository.filterWardrobeItems(
      category: category,
      subcategory: subcategory,
      color: color,
      brand: brand,
      name: name,
      isFavorite: isFavorite,
      isArchived: isArchived,
      userId: userId,
      season: season,
      style: style,
      occasions: occasions,
    );
  }

  // Business logic methods
  List<WardrobeItem> getRecommendedItemsForWeather(double temperature, String weatherCondition) {
    // This would typically call a repository method that filters items based on weather compatibility
    // For now, we'll return an empty list and implement the logic later
    return [];
  }

  List<WardrobeItem> getSeasonalItems(String season) {
    // This would typically call a repository method that filters items based on season
    // For now, we'll return an empty list and implement the logic later
    return [];
  }

  List<WardrobeItem> getItemsByTemperatureRange(double minTemp, double maxTemp) {
    // This would typically call a repository method that filters items based on temperature range
    // For now, we'll return an empty list and implement the logic later
    return [];
  }

  List<WardrobeItem> searchItems(String query) {
    // This would typically call a repository method that searches items by name, tags, etc.
    // For now, we'll return an empty list and implement the logic later
    return [];
  }

  Future<void> updateLastWorn(String id, DateTime lastWorn) async {
    // Get the current item
    final currentItem = await getWardrobeItemById(id);
    if (currentItem != null) {
      // Update the last worn date
      final updatedItem = currentItem.copyWith(
        lastWornAt: lastWorn,
        wearCount: currentItem.wearCount + 1, // Increment wear count
      );
      await updateWardrobeItem(updatedItem);
    }
  }

  Future<void> incrementWearCount(String id) async {
    // Get the current item
    final currentItem = await getWardrobeItemById(id);
    if (currentItem != null) {
      // Increment the wear count
      final updatedItem = currentItem.copyWith(
        wearCount: currentItem.wearCount + 1,
      );
      await updateWardrobeItem(updatedItem);
    }
  }
}