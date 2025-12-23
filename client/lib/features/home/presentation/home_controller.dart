import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories/recommendation_repository.dart';

final homeTodayRecProvider = StreamProvider.autoDispose<RecommendationRow?>((ref) {
  final repo = ref.watch(recommendationRepositoryProvider);
  return repo.watchTodayLatest();
});

final homeControllerProvider =
    AutoDisposeNotifierProvider<HomeController, String?>(
  HomeController.new,
);

class HomeController extends AutoDisposeNotifier<String?> {
  @override
  String? build() => null; // error text

  Future<void> bootstrap() async {
    final repo = ref.read(recommendationRepositoryProvider);

    // Локальное покажется сразу, сеть — best effort.
    try { await repo.ensureToday(occasion: 'daily'); } catch (_) {}
    try { await repo.syncHistory(pages: 1, limit: 20); } catch (_) {}
  }

  Future<void> toggleFavorite(RecommendationRow rec) async {
    final repo = ref.read(recommendationRepositoryProvider);
    await repo.toggleFavorite(rec);
  }

  Map<String, dynamic> parseWeather(RecommendationRow rec) {
    try {
      return (jsonDecode(rec.weatherDataJson) as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> parseOutfit(RecommendationRow rec) {
    try {
      return (jsonDecode(rec.outfitDataJson) as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}