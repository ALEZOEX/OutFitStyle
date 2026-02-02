import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import 'package:collection/collection.dart';
import '../../../domain/entities/recommendation_entity.dart';

final homeControllerProvider =
    AutoDisposeNotifierProvider<HomeController, String?>(
  HomeController.new,
);

final homeTodayRecProvider = StreamProvider.autoDispose<RecommendationRow?>((ref) {
  final service = ref.watch(recommendationsDomainServiceProvider);
  return service.watchTodayLatest();
});

class HomeController extends AutoDisposeNotifier<String?> {
  @override
  String? build() => null;

  Future<void> bootstrap() async {
    final service = ref.read(recommendationsDomainServiceProvider);

    try {
      // Синхронизируем последние рекомендации (best effort)
      await service.syncFromServer();
      // Не выставляем success руками — данные придут через stream.
    } catch (e) {
      // Не показываем ошибку пользователю, т.к. у нас есть локальные данные
      // ignore: avoid_print
      // Network error during home bootstrap: $e - logging would be handled by error handler
    }
  }

  Map<String, dynamic> parseWeather(RecommendationRow rec) {
    try {
      return (jsonDecode(rec.weatherDataJson) as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  List<Map<String, dynamic>> parseOutfit(RecommendationRow rec) {
    try {
      final outfit = (jsonDecode(rec.outfitDataJson) as Map).cast<String, dynamic>();
      return (outfit['outfit'] is List)
          ? (outfit['outfit'] as List)
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : <Map<String, dynamic>>[];
    } catch (_) {
      return <Map<String, dynamic>>[];
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

  Stream<RecommendationRow?> watchTodayLatest() {
    final service = ref.read(recommendationsDomainServiceProvider);
    return service.watchTodayLatest();
  }
}