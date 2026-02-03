import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/states/ui_states.dart';
import '../../../domain/states/async_state.dart';
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
        recommendations: AsyncSuccess(recommendations),
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
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> generateRecommendation() async {
    try {
      final service = _ref.read(recommendationsDomainServiceProvider);
      await service.generateRecommendation();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
