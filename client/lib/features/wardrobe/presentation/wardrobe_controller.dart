import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/wardrobe_repository.dart';
import '../../../domain/states/async_state.dart' as app_state;

final wardrobeControllerProvider =
    AutoDisposeNotifierProvider<WardrobeController, app_state.AsyncState<List<WardrobeEntry>>>(
  WardrobeController.new,
);

final wardrobeStreamProvider = StreamProvider.autoDispose<List<WardrobeEntry>>((ref) {
  final repo = ref.watch(wardrobeRepositoryProvider);
  return repo.watchWardrobe(includeArchived: false);
});

class WardrobeController extends AutoDisposeNotifier<app_state.AsyncState<List<WardrobeEntry>>> {
  @override
  app_state.AsyncState<List<WardrobeEntry>> build() {
    // Состояние контроллера — поверх стрима. Экран при этом подписан на streamProvider.
    return const app_state.AsyncLoading();
  }

  Future<void> sync() async {
    final repo = ref.read(wardrobeRepositoryProvider);

    try {
      await repo.syncFromServer();
      // Не выставляем success руками — данные придут через stream.
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // ignore: avoid_print
      print('Network error during wardrobe sync: $e');
    }
  }

  Future<void> toggleFavorite(WardrobeEntry e) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.toggleFavorite(e);
  }

  Future<void> toggleArchived(WardrobeEntry e) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.toggleArchived(e);
  }

  Future<void> markWorn(WardrobeEntry e) async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.markWorn(e);
  }

  Future<void> prefetchImages() async {
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.prefetchMissingImages(limit: 40);
  }
}