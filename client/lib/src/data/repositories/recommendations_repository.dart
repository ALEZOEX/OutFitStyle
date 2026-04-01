import 'dart:convert';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import '../../domain/entities/outfit_recommendation.dart';
import '../../domain/repositories/i_recommendations_repository.dart';
import '../../utils/logger.dart';

/// Репозиторий рекомендаций
class RecommendationsRepository implements IRecommendationsRepository {
  final ApiClient apiClient;

  RecommendationsRepository({required this.apiClient});

  @override
  Future<List<OutfitRecommendation>> getUserRecommendations(
    String userId,
  ) async {
    AppLogger.info('[RecommendationsRepository] getUserRecommendations: userId=$userId');
    final response = await apiClient.get('/api/v1/recommendations');
    AppLogger.info('[RecommendationsRepository] getUserRecommendations response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items =
          data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      AppLogger.info('[RecommendationsRepository] Получено ${items.length} рекомендаций');
      return items
          .map(
            (item) =>
                OutfitRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw RecommendationsException('Не удалось загрузить рекомендации');
  }

  @override
  Future<OutfitRecommendation?> getRecommendationById(String id) async {
    final response = await apiClient.get('/api/v1/recommendations/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return OutfitRecommendation.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> saveRecommendation(OutfitRecommendation recommendation) async {
    final response = await apiClient.post(
      '/api/v1/recommendations',
      data: recommendation.toJson(),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw RecommendationsException('Не удалось сохранить рекомендацию');
    }
  }

  @override
  Future<void> updateRecommendation(OutfitRecommendation recommendation) async {
    final id = recommendation.id;
    if (id == null) {
      throw RecommendationsException('ID рекомендации не указан');
    }
    final response = await apiClient.put(
      '/api/v1/recommendations/$id',
      data: recommendation.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось обновить рекомендацию');
    }
  }

  @override
  Future<void> deleteRecommendation(String id) async {
    final response = await apiClient.delete('/api/v1/recommendations/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось удалить рекомендацию');
    }
  }

  @override
  Future<void> likeRecommendation(String id, bool liked) async {
    final response = await apiClient.post(
      '/api/v1/recommendations/$id/favorite',
      data: {'is_favorite': liked},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось лайкнуть рекомендацию');
    }
  }

  @override
  Future<void> saveRecommendationForLater(String id, bool saved) async {
    final response = await apiClient.post(
      '/api/v1/recommendations/$id/favorite',
      data: {'is_favorite': saved},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException(
        'Не удалось сохранить рекомендацию на потом',
      );
    }
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
    String weatherCondition,
    double temperature,
  ) async {
    final response = await apiClient.get(
      '/api/v1/recommendations',
      params: {
        'condition': weatherCondition,
        'temperature': temperature.toString(),
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items =
          data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map(
            (item) =>
                OutfitRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw RecommendationsException(
      'Не удалось получить рекомендации по погоде',
    );
  }

  @override
  Future<List<OutfitRecommendation>> getTrendingRecommendations() async {
    final response = await apiClient.get('/api/v1/recommendations');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items =
          data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map(
            (item) =>
                OutfitRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw RecommendationsException(
      'Не удалось получить трендовые рекомендации',
    );
  }

  @override
  Future<void> submitFeedback(String recommendationId, String feedback) async {
    final response = await apiClient.post(
      '/api/v1/recommendations/$recommendationId/rate',
      data: {'feedback': feedback},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось отправить отзыв');
    }
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsHistory(
    String userId,
  ) async {
    final response = await apiClient.get('/api/v1/recommendations');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items =
          data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map(
            (item) =>
                OutfitRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw RecommendationsException('Не удалось получить историю рекомендаций');
  }

  @override
  Future<List<OutfitRecommendation>> getSavedRecommendations(
    String userId,
  ) async {
    final response = await apiClient.get('/api/v1/recommendations/favorites');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items =
          data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map(
            (item) =>
                OutfitRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw RecommendationsException(
      'Не удалось получить сохранённые рекомендации',
    );
  }

  @override
  Future<OutfitRecommendation> generateRecommendation({
    required List<String> excludedItems,
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
    required String userId,
  }) async {
    AppLogger.info('[RecommendationsRepository] generateRecommendation вызван');
    AppLogger.info('[RecommendationsRepository] latitude: $latitude, longitude: $longitude');
    AppLogger.info('[RecommendationsRepository] occasion: $occasion, preferredStyles: $preferredStyles');
    AppLogger.info('[RecommendationsRepository] userId: $userId, excludedItems: $excludedItems');
    
    final response = await apiClient.post(
      '/api/v1/recommendations',
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'occasion': occasion,
      },
    );
    
    AppLogger.info('[RecommendationsRepository] generateRecommendation response: ${response.statusCode}');
    AppLogger.info('[RecommendationsRepository] Response data: ${response.data}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final recData = data['recommendation'] as Map<String, dynamic>? ?? data;
      AppLogger.info('[RecommendationsRepository] Рекомендация: $recData');
      return OutfitRecommendation.fromJson(recData);
    }
    throw RecommendationsException('Не удалось сгенерировать рекомендацию');
  }

  @override
  Future<OutfitRecommendation> getMatchingItemsForRecommendation({
    required String occasion,
    required double temperature,
    required String weatherCondition,
    required String userId,
  }) async {
    final response = await apiClient.get(
      '/api/v1/recommendations',
      params: {
        'occasion': occasion,
        'temperature': temperature.toString(),
        'condition': weatherCondition,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? [];
      if (items.isNotEmpty) {
        return OutfitRecommendation.fromJson(
          items.first as Map<String, dynamic>,
        );
      }
    }
    throw RecommendationsException('Не удалось подобрать элементы');
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsByUser(
    String userId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final params = <String, dynamic>{
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };
    final response = await apiClient.get(
      '/api/v1/recommendations',
      params: params,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items =
          data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map(
            (item) =>
                OutfitRecommendation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    throw RecommendationsException(
      'Не удалось получить рекомендации пользователя',
    );
  }

  @override
  Future<void> rateRecommendation(String id, double rating) async {
    final response = await apiClient.post(
      '/api/v1/recommendations/$id/rate',
      data: {'rating': rating.toInt()},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось оценить рекомендацию');
    }
  }
}

/// Исключение репозитория рекомендаций
class RecommendationsException implements Exception {
  final String message;
  const RecommendationsException(this.message);

  @override
  String toString() => 'RecommendationsException: $message';
}
