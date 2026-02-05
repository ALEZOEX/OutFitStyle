import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/wardrobe_entity.dart' as domain;
import '../../../domain/states/wardrobe_state.dart';
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
        wardrobeItems: AsyncValue.data(items),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        wardrobeItems: AsyncValue.error(e, StackTrace.current),
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

  Future<void> prefetchImages(List<domain.WardrobeEntry> items) async {
    final imageStore = _ref.read(imageStoreProvider);
    await imageStore.prefetchImages(items);
  }

  Future<void> toggleFavorite(domain.WardrobeEntry item) async {
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      await repo.updateOne(updatedItem);
      // Also update the state to reflect the change
      final currentState = state.wardrobeItems;
      if (currentState.hasValue) {
        final currentList = currentState.value ?? [];
        final updatedList = currentList.map((wardrobeItem) {
          if (wardrobeItem.id == item.id) {
            return updatedItem;
          }
          return wardrobeItem;
        }).toList();
        state = state.copyWith(
          wardrobeItems: AsyncValue.data(updatedList),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleArchived(domain.WardrobeEntry item) async {
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final updatedItem = item.copyWith(isArchived: !item.isArchived);
      await repo.updateOne(updatedItem);
      // Also update the state to reflect the change
      final currentState = state.wardrobeItems;
      if (currentState.hasValue) {
        final currentList = currentState.value ?? [];
        final updatedList = currentList.map((wardrobeItem) {
          if (wardrobeItem.id == item.id) {
            return updatedItem;
          }
          return wardrobeItem;
        }).toList();
        state = state.copyWith(
          wardrobeItems: AsyncValue.data(updatedList),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markWorn(domain.WardrobeEntry item) async {
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final updatedItem = item.copyWith(
        wearCount: item.wearCount + 1,
        lastWornAt: DateTime.now(),
      );
      await repo.updateOne(updatedItem);
      // Also update the state to reflect the change
      final currentState = state.wardrobeItems;
      if (currentState.hasValue) {
        final currentList = currentState.value ?? [];
        final updatedList = currentList.map((wardrobeItem) {
          if (wardrobeItem.id == item.id) {
            return updatedItem;
          }
          return wardrobeItem;
        }).toList();
        state = state.copyWith(
          wardrobeItems: AsyncValue.data(updatedList),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
