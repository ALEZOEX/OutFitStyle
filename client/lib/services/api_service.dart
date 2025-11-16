import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/recommendation.dart';
import '../models/favorite.dart';
import '../models/achievement.dart'; // Добавляем импорт модели достижений

class ApiService {
  // Берем URL из конфигурации
  String get baseUrl => AppConfig.apiBaseUrl;

  Future<Recommendation> getRecommendations(String city,
      {int userId = 1}) async {
    try {
      final url =
          Uri.parse('$baseUrl/api/recommend?city=$city&user_id=$userId');

      // Логируем если включено
      if (AppConfig.enableLogging) {
        print('🌐 Platform: ${AppConfig.info['platform']}');
        print('🌐 API URL: $baseUrl');
        print('🌐 Full URL: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: AppConfig.requestTimeout),
        onTimeout: () {
          throw Exception('Request timeout - проверьте подключение');
        },
      );

      if (AppConfig.enableLogging) {
        print('📡 Response status: ${response.statusCode}');
        // Логируем тело ошибки
        if (response.statusCode != 200) {
          print('❌ Response body: ${response.body}');
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Recommendation.fromJson(data);
      } else {
        // Формируем более понятную ошибку
        String errorMessage = 'HTTP ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody['error'] != null) {
            errorMessage = errorBody['error'];
          }
        } catch (_) {
          // Если тело не JSON, возвращаем как есть
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('❌ Error: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/users/profile?user_id=$userId');
      final response = await http.get(url).timeout(
            Duration(seconds: AppConfig.requestTimeout),
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rateRecommendation({
    required int userId,
    required int recommendationId,
    required int itemId,
    required int overallRating,
    int? comfortRating,
    int? styleRating,
    int? weatherMatchRating,
    String? comment,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/ratings/rate');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': userId,
              'recommendation_id': recommendationId,
              'item_id': itemId,
              'overall_rating': overallRating,
              'comfort_rating': comfortRating,
              'style_rating': styleRating,
              'weather_match_rating': weatherMatchRating,
              'comment': comment,
            }),
          )
          .timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode != 200) {
        throw Exception('Failed to submit rating');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Новые методы для работы с избранными комплектами
  Future<void> addFavorite(int userId, int recommendationId) async {
    try {
      final url = Uri.parse('$baseUrl/api/favorites');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'recommendation_id': recommendationId,
        }),
      ).timeout(Duration(seconds: AppConfig.requestTimeout));

      if (response.statusCode != 201) {
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FavoriteOutfit>> getFavorites({required int userId}) async {
    try {
      final url = Uri.parse('$baseUrl/api/favorites?user_id=$userId');
      final response = await http.get(url).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => FavoriteOutfit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFavorite(int favoriteId) async {
    try {
      final url = Uri.parse('$baseUrl/api/favorites?id=$favoriteId');
      final response = await http.delete(url).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete favorite');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Метод для получения истории рекомендаций
  Future<List<Recommendation>> getRecommendationHistory({required int userId}) async {
    try {
      final url = Uri.parse('$baseUrl/api/recommendations/history?user_id=$userId');
      final response = await http.get(url).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyData = data['history'] ?? [];
        return historyData.map((json) => Recommendation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Метод для получения достижений пользователя
  Future<List<Achievement>> getAchievements({required int userId}) async {
    try {
      final url = Uri.parse('$baseUrl/api/achievements?user_id=$userId');
      final response = await http.get(url).timeout(
        Duration(seconds: AppConfig.requestTimeout),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Achievement.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load achievements');
      }
    } catch (e) {
      rethrow;
    }
  }
}