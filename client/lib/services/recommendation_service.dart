import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recommendation_models.dart';
import '../services/auth_storage.dart';

class RecommendationService {
  final String baseUrl;
  final AuthStorage authStorage;

  RecommendationService({required this.baseUrl, required this.authStorage});

  String get _apiUrl {
    // Убедимся, что baseUrl заканчивается на /api/v1
    if (!baseUrl.endsWith('/api/v1')) {
      if (baseUrl.endsWith('/')) {
        return baseUrl + 'api/v1';
      } else {
        return baseUrl + '/api/v1';
      }
    }
    return baseUrl;
  }

  Future<RecommendationRecord> createUsingProfile({required String occasion}) async {
    final token = await authStorage.readAccessToken();
    final response = await http.post(
      Uri.parse('$_apiUrl/recommendations'), // Убрано /generate
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'occasion': occasion}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Проверяем обертку и извлекаем вложенный объект
      if (json.containsKey('recommendation')) {
        return RecommendationRecord.fromJson(json['recommendation']);
      } else {
        // Если обертки нет, используем сам объект (как в рекомендации)
        return RecommendationRecord.fromJson(json);
      }
    } else {
      throw Exception('Failed to create recommendation: ${response.statusCode}');
    }
  }

  Future<(List<RecommendationRecord>, int total)> list({required int page, required int limit}) async {
    final token = await authStorage.readAccessToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/recommendations?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Используем правильные ключи: 'recommendations' и 'pagination.total'
      final List<dynamic> listJson = json['recommendations'] as List;
      final List<RecommendationRecord> items = listJson
          .map((e) => RecommendationRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      // Используем pagination.total
      final int total = json['pagination']['total'] as int;
      return (items, total);
    } else {
      throw Exception('Failed to list recommendations: ${response.statusCode}');
    }
  }

  Future<void> setFavorite({required String recommendationId, required bool isFavorite}) async {
    final token = await authStorage.readAccessToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/recommendations/$recommendationId/favorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // Изменяем ключ с 'value' на 'is_favorite'
      body: jsonEncode({'is_favorite': isFavorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }
}