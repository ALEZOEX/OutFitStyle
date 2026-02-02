import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/states/async_state.dart' as app_state;
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/entities/wardrobe_request_entities.dart';
import '../../../domain/states/ui_states.dart';

final wardrobeControllerProvider =
    StateNotifierProvider<WardrobeController, WardrobeState>(
  WardrobeController.new,
);

final wardrobeStreamProvider = StreamProvider.autoDispose<List<WardrobeEntry>>((ref) {
  final service = ref.watch(wardrobeDomainServiceProvider);
  return service.watchWardrobe(includeArchived: false);
});

class WardrobeController extends StateNotifier<WardrobeState> {
  WardrobeController() : super(WardrobeState());

  Future<void> sync() async {
    final service = ref.read(wardrobeDomainServiceProvider);

    try {
      await service.syncFromServer();
      // Не выставляем success руками — данные придут через stream.
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // ignore: avoid_print
      // print('Wardrobe sync error: $e'); // Logging would be handled by error handler
    }
  }

  Future<void> toggleFavorite(WardrobeEntry e) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    await service.toggleFavorite(e);
  }

  Future<void> toggleArchived(WardrobeEntry e) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    await service.toggleArchived(e);
  }

  Future<void> markWorn(WardrobeEntry e) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    await service.markWorn(e);
  }

  Future<void> prefetchImages() async {
    final service = ref.read(wardrobeDomainServiceProvider);
    await service.prefetchMissingImages(limit: 40);
  }

  // CRUD операции для полноценного гардероба
  Future<WardrobeEntry> createWardrobeItem(WardrobeItemCreateRequest request) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    return await service.createItem(request);
  }

  Future<void> updateWardrobeItem(String id, WardrobeItemUpdateRequest request) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    await service.updateItem(id, request);
  }

  Future<void> deleteWardrobeItem(String id) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    await service.deleteItem(id);
  }

  Future<WardrobeEntry> getWardrobeItemById(String id) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    return await service.getById(id);
  }

  Future<List<WardrobeEntry>> getItemsForRecommendation({String? category, String? season, String? weather}) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    return await service.getItemsForRecommendation(
      category: category,
      season: season,
      weather: weather,
    );
  }

  Future<WardrobeEntry?> getById(String id) async {
    final service = ref.read(wardrobeDomainServiceProvider);
    return await service.getById(id);
  }
}