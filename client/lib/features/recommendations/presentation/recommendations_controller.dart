import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/states/async_state.dart' as app_state;
import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/states/ui_states.dart';

final recommendationsControllerProvider =
    StateNotifierProvider<RecommendationsController, RecommendationsState>(
  RecommendationsController.new,
);

final recommendationsStreamProvider = StreamProvider.autoDispose<List<RecommendationRow>>((ref) {
  final service = ref.watch(recommendationsDomainServiceProvider);
  return service.watchHistory(limit: 50);
});

final recommendationByIdProvider =
    StreamProvider.autoDispose.family<RecommendationRow?, String>((ref, id) {
  final service = ref.watch(recommendationsDomainServiceProvider);
  return service.watchById(id);
});

class RecommendationsController extends StateNotifier<RecommendationsState> {
  RecommendationsController() : super(RecommendationsState());

  Future<void> sync() async {
    final service = ref.read(recommendationsDomainServiceProvider);

    try {
      await service.syncFromServer();
      // Не выставляем success руками — данные придут через stream.
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // ignore: avoid_print
      // print('Recommendations sync error: $e'); // Logging would be handled by error handler
    }
  }

  Future<void> toggleFavorite(RecommendationRow r) async {
    final service = ref.read(recommendationsDomainServiceProvider);
    await service.toggleFavorite(r);
  }

  Future<void> prefetchImages() async {
    final service = ref.read(recommendationsDomainServiceProvider);
    await service.prefetchMissingImages(limit: 40);
  }

  // Методы для интеграции с гардеробом
  Future<RecommendationRow> createLocal({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
  }) async {
    final service = ref.read(recommendationsDomainServiceProvider);
    return await service.createLocal(
      outfitData: outfitData,
      weatherData: weatherData,
    );
  }

  Future<RecommendationRow> generateRecommendation({required String occasion}) async {
    final service = ref.read(recommendationsDomainServiceProvider);
    return await service.generateRecommendation(occasion: occasion);
  }

  Future<RecommendationRow> generateRecommendationWithItem({
    required WardrobeEntry item,
    required String occasion,
    bool includeWeather = true,
  }) async {
    final service = ref.read(recommendationsDomainServiceProvider);
    return await service.generateRecommendationWithItem(
      item: item,
      occasion: occasion,
      includeWeather: includeWeather,
    );
  }

  Future<RecommendationRow> saveLocalOutfit({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
    required bool favorite,
  }) async {
    final service = ref.read(recommendationsDomainServiceProvider);
    return await service.saveLocalOutfit(
      outfitData: outfitData,
      weatherData: weatherData,
      favorite: favorite,
    );
  }

  Future<RecommendationRow?> getById(String id) async {
    final service = ref.read(recommendationsDomainServiceProvider);
    try {
      return await service.getById(id);
    } catch (e) {
      // Если ошибка получения, возвращаем null
      return null;
    }
  }

  Stream<RecommendationRow?> watchById(String id) {
    final service = ref.read(recommendationsDomainServiceProvider);
    return service.watchById(id);
  }
}