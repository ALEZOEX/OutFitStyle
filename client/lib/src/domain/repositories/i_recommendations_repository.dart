import '../entities/outfit_recommendation.dart';

/// Интерфейс репозитория рекомендаций
abstract class IRecommendationsRepository {
  /// Получить рекомендации для пользователя
  Future<List<OutfitRecommendation>> getUserRecommendations(String userId);

  /// Получить рекомендацию по ID
  Future<OutfitRecommendation?> getRecommendationById(String id);

  /// Сохранить рекомендацию
  Future<void> saveRecommendation(OutfitRecommendation recommendation);

  /// Обновить рекомендацию
  Future<void> updateRecommendation(OutfitRecommendation recommendation);

  /// Удалить рекомендацию
  Future<void> deleteRecommendation(String id);

  /// Лайкнуть рекомендацию
  Future<void> likeRecommendation(String id, bool liked);

  /// Сохранить рекомендацию на потом
  Future<void> saveRecommendationForLater(String id, bool saved);

  /// Получить рекомендации по погоде
  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
      String weatherCondition, double temperature);

  /// Получить трендовые рекомендации
  Future<List<OutfitRecommendation>> getTrendingRecommendations();

  /// Отправить отзыв о рекомендации
  Future<void> submitFeedback(String recommendationId, String feedback);

  /// Получить историю рекомендаций
  Future<List<OutfitRecommendation>> getRecommendationsHistory(String userId);

  /// Получить сохраненные рекомендации
  Future<List<OutfitRecommendation>> getSavedRecommendations(String userId);

  /// Сгенерировать рекомендацию
  Future<OutfitRecommendation> generateRecommendation({
    required List<String> excludedItems,
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  });

  /// Получить подходящие элементы для рекомендации
  Future<OutfitRecommendation> getMatchingItemsForRecommendation({
    required String occasion,
    required double temperature,
    required String weatherCondition,
    required String userId,
  });

  /// Получить рекомендации по пользователю
  Future<List<OutfitRecommendation>> getRecommendationsByUser(
      String userId, {DateTime? fromDate, DateTime? toDate});

  /// Оценить рекомендацию
  Future<void> rateRecommendation(String id, double rating);
}