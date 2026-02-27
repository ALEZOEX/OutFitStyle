import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../data/repositories/daily_recommendations_repository.dart';
import '../../../../domain/entities/outfit_recommendation.dart';
import '../../../../ui/widgets/city_selector_widget.dart';

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
/// Использует координаты выбранного города или дефолтные (Москва)
final dailyRecommendationProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(dailyRecommendationsRepositoryProvider);
  final selectedCity = ref.watch(selectedCityProvider);
  
  // Используем координаты выбранного города или дефолтные (Москва)
  final latitude = selectedCity?.lat ?? 55.7558;
  final longitude = selectedCity?.lon ?? 37.6173;
  
  return repository.getDailyRecommendation(
    latitude: latitude,
    longitude: longitude,
  );
});

/// Провайдер для загрузки альтернативных рекомендаций
/// Использует координаты выбранного города
final alternativeRecommendationsProvider = FutureProvider.autoDispose.family<List<OutfitRecommendation>, int>((ref, limit) async {
  final repository = ref.watch(dailyRecommendationsRepositoryProvider);
  final selectedCity = ref.watch(selectedCityProvider);
  
  // Используем координаты выбранного города или дефолтные (Москва)
  final latitude = selectedCity?.lat ?? 55.7558;
  final longitude = selectedCity?.lon ?? 37.6173;
  
  return repository.getAlternativeRecommendations(
    latitude: latitude,
    longitude: longitude,
    limit: limit,
  );
});

/// Провайдер для загрузки советов дня
final dailyTipsProvider = FutureProvider.autoDispose.family<List<Tip>, int>((ref, limit) async {
  final repository = ref.watch(dailyRecommendationsRepositoryProvider);
  return repository.getDailyTips(limit: limit);
});
