import '../../../../core/api/api_client.dart';
import '../../../../domain/entities/outfit_recommendation.dart';
import 'package:dio/dio.dart';

/// Репозиторий для работы с ежедневными рекомендациями
///
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/recommendations/daily - ежедневная рекомендация
/// - GET /api/v1/recommendations/alternatives - альтернативные варианты
/// - GET /api/v1/tips/daily - советы дня
class DailyRecommendationsRepository {
  final ApiClient _apiClient;

  DailyRecommendationsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Получить ежедневную рекомендацию
  ///
  /// Endpoint: GET /api/v1/recommendations/daily
  Future<OutfitRecommendation> getDailyRecommendation() async {
    try {
      final response = await _apiClient.get('/api/v1/recommendations/daily');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final recData = data['recommendation'] as Map<String, dynamic>? ?? data;
        return OutfitRecommendation.fromJson(recData);
      } else {
        throw RecommendationsException('Ошибка получения рекомендации: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка получения рекомендации: $e');
    }
  }

  /// Получить альтернативные рекомендации
  ///
  /// [limit] - количество рекомендаций (по умолчанию 3)
  ///
  /// Endpoint: GET /api/v1/recommendations/alternatives
  Future<List<OutfitRecommendation>> getAlternativeRecommendations({int limit = 3}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/recommendations/alternatives',
        params: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final recsData = data['recommendations'] as List<dynamic>? ??
                         data['alternatives'] as List<dynamic>? ??
                         [];

        return recsData
            .map((item) => OutfitRecommendation.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw RecommendationsException('Ошибка получения рекомендаций: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка получения рекомендаций: $e');
    }
  }

  /// Получить советы дня
  ///
  /// [limit] - количество советов (по умолчанию 4)
  ///
  /// Endpoint: GET /api/v1/tips/daily
  Future<List<Tip>> getDailyTips({int limit = 4}) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/tips/daily',
        params: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tipsData = data['tips'] as List<dynamic>? ?? [];

        return tipsData
            .map((item) => Tip.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw RecommendationsException('Ошибка получения советов: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка получения советов: $e');
    }
  }

  /// Создать новую рекомендацию
  ///
  /// [latitude] - широта
  /// [longitude] - долгота
  /// [occasion] - повод
  ///
  /// Endpoint: POST /api/v1/recommendations
  Future<OutfitRecommendation> createRecommendation({
    double? latitude,
    double? longitude,
    String? occasion,
    String? location,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (occasion != null) body['occasion'] = occasion;
      if (location != null) body['location'] = location;

      final response = await _apiClient.post('/api/v1/recommendations', data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final recData = data['recommendation'] as Map<String, dynamic>? ?? data;
        return OutfitRecommendation.fromJson(recData);
      } else {
        throw RecommendationsException('Ошибка создания рекомендации: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка создания рекомендации: $e');
    }
  }

  /// Оценить рекомендацию
  ///
  /// [id] - ID рекомендации
  /// [rating] - оценка (1-5)
  ///
  /// Endpoint: POST /api/v1/recommendations/{id}/rate
  Future<void> rateRecommendation(String id, double rating) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/recommendations/$id/rate',
        data: {'rating': rating},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw RecommendationsException('Ошибка оценки рекомендации: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка оценки рекомендации: $e');
    }
  }

  /// Добавить рекомендацию в избранное
  ///
  /// [id] - ID рекомендации
  ///
  /// Endpoint: POST /api/v1/recommendations/{id}/favorite
  Future<OutfitRecommendation> toggleFavorite(String id) async {
    try {
      final response = await _apiClient.post('/api/v1/recommendations/$id/favorite');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final recData = data['recommendation'] as Map<String, dynamic>? ?? data;
        return OutfitRecommendation.fromJson(recData);
      } else {
        throw RecommendationsException('Ошибка обновления избранного: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка обновления избранного: $e');
    }
  }

  /// Сохранить рекомендацию
  ///
  /// [id] - ID рекомендации
  ///
  /// Endpoint: POST /api/v1/recommendations/{id}/save
  Future<OutfitRecommendation> saveRecommendation(String id) async {
    try {
      final response = await _apiClient.post('/api/v1/recommendations/$id/save');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final recData = data['recommendation'] as Map<String, dynamic>? ?? data;
        return OutfitRecommendation.fromJson(recData);
      } else {
        throw RecommendationsException('Ошибка сохранения рекомендации: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is RecommendationsException) rethrow;
      throw RecommendationsException('Ошибка сохранения рекомендации: $e');
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw RecommendationsException('Превышено время ожидания. Проверьте соединение.');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      throw RecommendationsException('Нет соединения с интернетом.');
    }
    
    final statusCode = e.response?.statusCode;
    final errorMessage = _extractErrorMessage(e.response?.data);
    
    switch (statusCode) {
      case 401:
        throw RecommendationsException('Требуется авторизация');
      case 403:
        throw RecommendationsException('Нет доступа');
      case 404:
        throw RecommendationsException('Рекомендация не найдена');
      case 422:
        throw RecommendationsException(errorMessage ?? 'Неверные данные');
      case 500:
        throw RecommendationsException('Ошибка сервера');
      default:
        throw RecommendationsException('Ошибка сети: ${e.message}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 
             data['error'] as String?;
    }
    return null;
  }
}

/// Совет дня
class Tip {
  final String id;
  final String text;
  final String category;

  Tip({
    required this.id,
    required this.text,
    required this.category,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String? ?? 'general',
    );
  }
}

/// Исключение репозитория рекомендаций
class RecommendationsException implements Exception {
  final String message;
  
  const RecommendationsException(this.message);
  
  @override
  String toString() => 'RecommendationsException: $message';
}
