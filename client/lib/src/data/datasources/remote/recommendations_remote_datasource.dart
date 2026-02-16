import 'dart:convert';
import '../../remote/api_client.dart';
import '../../../domain/entities/outfit_recommendation.dart';

abstract class IRecommendationsRemoteDataSource {
  Future<List<OutfitRecommendation>> getUserRecommendations(String userId);
  Future<OutfitRecommendation?> getRecommendationById(String id);
  Future<void> saveRecommendation(OutfitRecommendation recommendation);
  Future<void> updateRecommendation(OutfitRecommendation recommendation);
  Future<void> deleteRecommendation(String id);
  Future<void> likeRecommendation(String id, bool liked);
  Future<void> saveRecommendationForLater(String id, bool saved);
  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
      String weatherCondition, double temperature);
  Future<List<OutfitRecommendation>> getTrendingRecommendations();
  Future<void> submitFeedback(String recommendationId, String feedback);
}

class RecommendationsRemoteDataSource implements IRecommendationsRemoteDataSource {
  final ApiClient _apiClient;

  RecommendationsRemoteDataSource(this._apiClient);

  @override
  Future<List<OutfitRecommendation>> getUserRecommendations(String userId) async {
    final response = await _apiClient.get('/users/$userId/recommendations');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsRemoteException('Не удалось загрузить рекомендации');
  }

  @override
  Future<OutfitRecommendation?> getRecommendationById(String id) async {
    final response = await _apiClient.get('/recommendations/$id');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return OutfitRecommendation.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> saveRecommendation(OutfitRecommendation recommendation) async {
    final response = await _apiClient.post(
      '/recommendations',
      body: recommendation.toJson(),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw RecommendationsRemoteException('Не удалось сохранить рекомендацию');
    }
  }

  @override
  Future<void> updateRecommendation(OutfitRecommendation recommendation) async {
    final id = recommendation.id;
    if (id == null) {
      throw RecommendationsRemoteException('ID рекомендации не указан');
    }
    final response = await _apiClient.put(
      '/recommendations/$id',
      body: recommendation.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsRemoteException('Не удалось обновить рекомендацию');
    }
  }

  @override
  Future<void> deleteRecommendation(String id) async {
    final response = await _apiClient.delete('/recommendations/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsRemoteException('Не удалось удалить рекомендацию');
    }
  }

  @override
  Future<void> likeRecommendation(String id, bool liked) async {
    final response = await _apiClient.post(
      '/recommendations/$id/like',
      body: {'liked': liked},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsRemoteException('Не удалось лайкнуть рекомендацию');
    }
  }

  @override
  Future<void> saveRecommendationForLater(String id, bool saved) async {
    final response = await _apiClient.post(
      '/recommendations/$id/save',
      body: {'saved': saved},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsRemoteException('Не удалось сохранить рекомендацию на потом');
    }
  }

  @override
  Future<List<OutfitRecommendation>> getRecommendationsByWeather(
      String weatherCondition, double temperature) async {
    final response = await _apiClient.get(
      '/recommendations/weather',
      params: {
        'condition': weatherCondition,
        'temperature': temperature.toString(),
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsRemoteException('Не удалось получить рекомендации по погоде');
  }

  @override
  Future<List<OutfitRecommendation>> getTrendingRecommendations() async {
    final response = await _apiClient.get('/recommendations/trending');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['recommendations'] as List<dynamic>? ?? data as List<dynamic>;
      return items
          .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw RecommendationsRemoteException('Не удалось получить трендовые рекомендации');
  }

  @override
  Future<void> submitFeedback(String recommendationId, String feedback) async {
    final response = await _apiClient.post(
      '/recommendations/$recommendationId/feedback',
      body: {'feedback': feedback},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw RecommendationsRemoteException('Не удалось отправить отзыв');
    }
  }
}

/// Исключение remote datasource рекомендаций
class RecommendationsRemoteException implements Exception {
  final String message;
  const RecommendationsRemoteException(this.message);

  @override
  String toString() => 'RecommendationsRemoteException: $message';
}