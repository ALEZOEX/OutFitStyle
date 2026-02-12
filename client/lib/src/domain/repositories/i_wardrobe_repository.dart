import '../entities/wardrobe.dart';

abstract class IWardrobeRepository {
  Future<List<WardrobeItem>> getAllWardrobeItems({bool includeArchived = false});
  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false});
  Future<WardrobeItem?> getWardrobeItemById(String id);
  Future<void> addWardrobeItem(WardrobeItem item);
  Future<void> updateWardrobeItem(WardrobeItem item);
  Future<void> deleteWardrobeItem(String id);
  Future<void> archiveWardrobeItem(String id);
  Future<void> restoreWardrobeItem(String id);
  Future<void> syncFromServer();
  Future<void> prefetchMissingImages();
}