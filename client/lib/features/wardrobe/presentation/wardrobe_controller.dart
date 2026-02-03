import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/entities/wardrobe_request_entities.dart';
import '../../../domain/states/wardrobe_state.dart';
import '../../../domain/states/async_state.dart';
import '../../../app/di.dart';

class WardrobeController extends StateNotifier<WardrobeState> {
  final Ref _ref;

  WardrobeController(this._ref) : super(const WardrobeState());

  Future<void> loadWardrobe() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final items = await repo.getAll();
      state = state.copyWith(
        isLoading: false,
        wardrobeItems: const AsyncSuccess([]), // Will be updated with actual items
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sync() async {
    try {
      final worker = _ref.read(syncWorkerProvider);
      await worker.syncWardrobe();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> prefetchImages(List<WardrobeEntry> items) async {
    final imageStore = _ref.read(imageStoreProvider);
    await imageStore.prefetchImages(items);
  }

  Future<void> toggleFavorite(WardrobeEntry item) async {
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      await repo.update(updatedItem);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleArchived(WardrobeEntry item) async {
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final updatedItem = item.copyWith(isArchived: !item.isArchived);
      await repo.update(updatedItem);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markWorn(WardrobeEntry item) async {
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final updatedItem = item.copyWith(
        wearCount: item.wearCount + 1,
        lastWornAt: DateTime.now(),
      );
      await repo.update(updatedItem);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
