import '../entities/wardrobe_item.dart';
import '../repositories/i_wardrobe_repository.dart';

/// Доменный сервис для работы с гардеробом
class WardrobeDomainService {
  final IWardrobeRepository _repository;

  WardrobeDomainService(this._repository);

  Future<List<WardrobeItem>> getAllWardrobeItems({
    bool includeArchived = false,
  }) async {
    return await _repository.getAllWardrobeItems(
      includeArchived: includeArchived,
    );
  }

  Stream<List<WardrobeItem>> watchWardrobe({bool includeArchived = false}) {
    return _repository.watchWardrobe(includeArchived: includeArchived);
  }

  Future<WardrobeItem?> getWardrobeItemById(String id) async {
    return await _repository.getWardrobeItemById(id);
  }

  Future<void> addWardrobeItem(WardrobeItem item) async {
    return await _repository.addWardrobeItem(item);
  }

  Future<void> updateWardrobeItem(WardrobeItem item) async {
    return await _repository.updateWardrobeItem(item);
  }

  Future<void> deleteWardrobeItem(String id) async {
    return await _repository.deleteWardrobeItem(id);
  }

  Future<void> archiveWardrobeItem(String id) async {
    return await _repository.archiveWardrobeItem(id);
  }

  Future<void> restoreWardrobeItem(String id) async {
    return await _repository.restoreWardrobeItem(id);
  }

  Future<void> syncFromServer() async {
    return await _repository.syncFromServer();
  }

  Future<void> prefetchMissingImages() async {
    return await _repository.prefetchMissingImages();
  }
}
