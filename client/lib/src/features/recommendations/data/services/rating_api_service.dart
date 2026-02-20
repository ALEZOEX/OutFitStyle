import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../domain/entities/outfit_rating.dart';

/// API сервис для управления рейтингом рекомендаций
class RatingApiService {
  final ApiClient _client;

  RatingApiService({required ApiClient client}) : _client = client;

  /// Оценить рекомендацию
  /// [recommendationId] - ID рекомендации
  /// [rating] - оценка 1-5 звёзд
  /// [outfitItems] - ID вещей в наряде
  /// [feedback] - текстовый отзыв (опционально)
  /// [thermalFeedback] - термальная обратная связь (опционально)
  Future<OutfitRating> rateOutfit({
    required String recommendationId,
    required int rating,
    List<int>? outfitItems,
    String? feedback,
    ThermalFeedback? thermalFeedback,
  }) async {
    final response = await _client.post(
      '/recommendations/$recommendationId/rate',
      data: {
        'rating': rating,
        'outfit_items': outfitItems ?? [],
        if (feedback != null) 'feedback': feedback,
        if (thermalFeedback != null) 'thermal_feedback': thermalFeedback.name,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final ratingData = data['rating'] as Map<String, dynamic>;
      return OutfitRating.fromJson(ratingData);
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось оценить наряд: ${response.data}',
      );
    }
  }

  /// Получить статистику качества рекомендации
  Future<RecommendationQuality> getQuality(String recommendationId) async {
    final response = await _client.get('/recommendations/$recommendationId/quality');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final qualityData = data['quality'] as Map<String, dynamic>;
      return RecommendationQuality.fromJson(qualityData);
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось получить статистику: ${response.data}',
      );
    }
  }

  /// Получить оценку пользователя для рекомендации
  Future<OutfitRating?> getUserRating(String recommendationId) async {
    final response = await _client.get('/recommendations/$recommendationId/my-rating');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final ratingData = data['rating'];
      if (ratingData == null) return null;
      return OutfitRating.fromJson(ratingData as Map<String, dynamic>);
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось получить оценку: ${response.data}',
      );
    }
  }

  /// Проверить, оценил ли пользователь рекомендацию
  Future<bool> hasRated(String recommendationId) async {
    final response = await _client.get('/recommendations/$recommendationId/has-rated');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      return data['has_rated'] as bool;
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось проверить оценку: ${response.data}',
      );
    }
  }

  /// Получить статистику оценок пользователя
  Future<UserRatingStats> getUserStats() async {
    final response = await _client.get('/ratings/me/stats');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final statsData = data['stats'] as Map<String, dynamic>;
      return UserRatingStats.fromJson(statsData);
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось получить статистику пользователя: ${response.data}',
      );
    }
  }

  /// Получить вещи с низким рейтингом для ML
  Future<List<int>> getLowQualityItems() async {
    final response = await _client.get('/ratings/low-quality-items');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final items = data['low_quality_items'] as List;
      return items.whereType<int>().toList();
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось получить вещи с низким рейтингом: ${response.data}',
      );
    }
  }

  /// Фильтровать вещи с низким рейтингом
  Future<List<String>> filterLowQualityItems({
    required List<String> candidateIds,
    double threshold = -5.0,
  }) async {
    final response = await _client.post(
      '/ratings/filter-low-quality',
      data: {
        'candidate_ids': candidateIds,
        'threshold': threshold,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final filteredIds = data['candidate_ids'] as List;
      return filteredIds.whereType<String>().toList();
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось отфильтровать вещи: ${response.data}',
      );
    }
  }

  /// Получить оценки пользователя для списка рекомендаций
  Future<Map<String, int>> getUserRatingsForRecommendations(
    List<String> recommendationIds,
  ) async {
    final response = await _client.post(
      '/ratings/bulk',
      data: {
        'recommendation_ids': recommendationIds,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final ratings = data['ratings'] as Map<String, dynamic>;
      return ratings.map((key, value) => MapEntry(key, value as int));
    } else {
      throw RatingApiException(
        statusCode: response.statusCode ?? 0,
        message: 'Не удалось получить оценки: ${response.data}',
      );
    }
  }
}

/// Исключение API сервиса рейтинга
class RatingApiException implements Exception {
  final int statusCode;
  final String message;

  RatingApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'RatingApiException($statusCode): $message';
}

/// Исключение API (устаревшее, для обратной совместимости)
@Deprecated('Используйте RatingApiException')
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
