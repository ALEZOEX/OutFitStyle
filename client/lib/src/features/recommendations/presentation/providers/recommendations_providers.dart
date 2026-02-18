import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/daily_recommendations_repository.dart';
import '../../../../domain/entities/outfit_recommendation.dart';

/// Провайдер для ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient должен быть предоставлен');
});

/// Провайдер репозитория рекомендаций
final dailyRecommendationsRepositoryProvider = Provider<DailyRecommendationsRepository>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return DailyRecommendationsRepository(apiClient: apiClient);
});

/// Провайдер для загрузки ежедневной рекомендации
final dailyRecommendationProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(dailyRecommendationsRepositoryProvider);
  return repository.getDailyRecommendation();
});

/// Провайдер для загрузки альтернативных рекомендаций
final alternativeRecommendationsProvider = FutureProvider.autoDispose.family<List<OutfitRecommendation>, int>((ref, limit) async {
  final repository = ref.watch(dailyRecommendationsRepositoryProvider);
  return repository.getAlternativeRecommendations(limit: limit);
});

/// Провайдер для загрузки советов дня
final dailyTipsProvider = FutureProvider.autoDispose.family<List<Tip>, int>((ref, limit) async {
  final repository = ref.watch(dailyRecommendationsRepositoryProvider);
  return repository.getDailyTips(limit: limit);
});
