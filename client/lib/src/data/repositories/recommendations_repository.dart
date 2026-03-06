import 'dart:convert';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import '../../domain/entities/outfit_recommendation.dart';
import '../../domain/repositories/i_recommendations_repository.dart';

/// Репозиторий рекомендаций
class RecommendationsRepository implements IRecommendationsRepository {
  final ApiClient apiClient;

  RecommendationsRepository({required this.apiClient});

  @override
  Future<List<OutfitRecommendation>> getUserRecommendations(String userId) async {
    final response = await apiClient.get('/users/$userId/recommendations');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsException('Не удалось загрузить рекомендации');
  }

  @override
  Future<OutfitRecommendation?> getRecommendationById(String id) async {
    final response = await apiClient.get('/recommendations/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return OutfitRecommendation.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> saveRecommendation(OutfitRecommendation recommendation) async {
    final response = await apiClient.post(
      '/recommendations',
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
      '/recommendations/$id',
      data: recommendation.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось обновить рекомендацию');
    }
  }

  @override
  Future<void> deleteRecommendation(String id) async {
    final response = await apiClient.delete('/recommendations/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось удалить рекомендацию');
    }
  }

  @override
  Future<void> likeRecommendation(String id, bool liked) async {
    final response = await apiClient.post(
      '/recommendations/$id/like',
      data: {'liked': liked},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось лайкнуть рекомендацию');
    }
  }

  @override
  Future<void> saveRecommendationForLater(String id, bool saved) async {
    final response = await apiClient.post(
      '/recommendations/$id/save',
      data: {'saved': saved},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось сохранить рекомендацию на потом');
    }
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
      String weatherCondition, double temperature) async {
    final response = await apiClient.get(
      '/recommendations/weather',
      params: {
        'condition': weatherCondition,
        'temperature': temperature.toString(),
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsException('Не удалось получить рекомендации по погоде');
  }

  @override
  Future<List<OutfitRecommendation>> getTrendingRecommendations() async {
    final response = await apiClient.get('/recommendations/trending');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsException('Не удалось получить трендовые рекомендации');
  }

  @override
  Future<void> submitFeedback(String recommendationId, String feedback) async {
    final response = await apiClient.post(
      '/recommendations/$recommendationId/feedback',
      data: {'feedback': feedback},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsException('Не удалось отправить отзыв');
    }
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsHistory(String userId) async {
    final response = await apiClient.get('/users/$userId/recommendations/history');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsException('Не удалось получить историю рекомендаций');
  }

  @override
  Future<List<OutfitRecommendation>> getSavedRecommendations(String userId) async {
    final response = await apiClient.get('/users/$userId/recommendations/saved');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsException('Не удалось получить сохранённые рекомендации');
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
    final response = await apiClient.post(
      '/recommendations/generate',
      data: {
        'user_id': userId,
        'excluded_items': excludedItems,
        'latitude': latitude,
        'longitude': longitude,
        'occasion': occasion,
        'preferred_styles': preferredStyles,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return OutfitRecommendation.fromJson(data);
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
      '/recommendations/match',
      params: {
        'user_id': userId,
        'occasion': occasion,
        'temperature': temperature.toString(),
        'weather_condition': weatherCondition,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      return OutfitRecommendation.fromJson(data);
    }
    throw RecommendationsException('Не удалось подобрать элементы');
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsByUser(
      String userId, {DateTime? fromDate, DateTime? toDate}) async {
    final params = <String, dynamic>{
      'user_id': userId,
      if (fromDate != null) 'from_date': fromDate.toIso8601String(),
      if (toDate != null) 'to_date': toDate.toIso8601String(),
    };
    final response = await apiClient.get('/recommendations/user', params: params);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsException('Не удалось получить рекомендации пользователя');
  }

  @override
  Future<void> rateRecommendation(String id, double rating) async {
    final response = await apiClient.post(
      '/recommendations/$id/rate',
      data: {'rating': rating},
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