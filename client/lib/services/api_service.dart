import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/recommendation.dart';

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
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Recommendation.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}');
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
}
