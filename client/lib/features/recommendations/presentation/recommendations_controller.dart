import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/states/recommendations_state.dart';
import '../../../app/di.dart';

class RecommendationsController extends StateNotifier<RecommendationsState> {
  final Ref _ref;

  RecommendationsController(this._ref) : super(const RecommendationsState());

  Future<void> loadRecommendations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(recommendationsRepositoryProvider);
      final recommendations = await repo.getAll();
      state = state.copyWith(
        isLoading: false,
        recommendations: AsyncValue.data(recommendations),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        recommendations: AsyncValue.error(e, StackTrace.current),
      );
    }
  }

  Future<void> sync() async {
    try {
      final worker = _ref.read(syncWorkerProvider);
      await worker.syncRecommendations();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> prefetchImages(List<RecommendationRow> items) async {
    final imageStore = _ref.read(imageStoreProvider);
    await imageStore.prefetchImagesForRecommendations(items);
  }

  Future<void> toggleFavorite(RecommendationRow item) async {
    try {
      final repo = _ref.read(recommendationsRepositoryProvider);
      final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
      await repo.update(updatedItem);
      // Also update the state to reflect the change
      final currentState = state.recommendations;
      if (currentState.hasValue) {
        final currentList = currentState.value ?? [];
        final updatedList = currentList.map((rec) {
          if (rec.id == item.id) {
            return updatedItem;
          }
          return rec;
        }).toList();
        state = state.copyWith(
          recommendations: AsyncValue.data(updatedList),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> generateRecommendation({required String occasion}) async {
    try {
      final service = _ref.read(recommendationsDomainServiceProvider);
      await service.generateRecommendation(occasion: occasion);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
