import 'dart:async';
import 'package:outfitstyle_client/domain/entities/wardrobe.dart';

abstract class IWardrobeRepository {
  // Local data sources
  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false});
  Stream<WardrobeItem?> watchById(String id);
  Future<List<WardrobeItem>> getAllWardrobeItems({String? userId});
  Future<WardrobeItem?> getWardrobeItemById(String id);
  Future<WardrobeItem> addWardrobeItem(WardrobeItem item);
  Future<WardrobeItem> updateWardrobeItem(WardrobeItem item);
  Future<void> deleteWardrobeItem(String id);
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
  });
  
  // Remote data sources
  Future<List<WardrobeItem>> getAllWardrobeItemsFromRemote({String? userId});
  Future<WardrobeItem> getWardrobeItemByIdFromRemote(String id);
  Future<WardrobeItem> createWardrobeItemToRemote(WardrobeItem item);
  Future<WardrobeItem> updateWardrobeItemToRemote(WardrobeItem item);
  Future<void> deleteWardrobeItemFromRemote(String id);
  Future<List<WardrobeItem>> filterWardrobeItemsFromRemote({
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
  });

  // Sync methods
  Future<void> syncWardrobe();
  Future<void> markAsSynced(String id, String remoteId);
}