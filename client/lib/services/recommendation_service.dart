import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recommendation_models.dart';
import '../services/auth_storage.dart';
import 'http_client.dart';
import '../app/api/api_config.dart';

class RecommendationService {
  final ApiConfig apiConfig;
  final AuthStorage authStorage;
  final http.Client httpClient;

  RecommendationService({required this.apiConfig, required this.authStorage, http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  String get _apiUrl {
    // Убедимся, что baseUrl заканчивается на /api/v1
    if (!apiConfig.apiBase.endsWith('/api/v1')) {
      if (apiConfig.apiBase.endsWith('/')) {
        return '${apiConfig.apiBase}api/v1';
      } else {
        return '${apiConfig.apiBase}/api/v1';
      }
    }
    return apiConfig.apiBase;
  }

  Future<RecommendationRecord> createUsingProfile({required String occasion}) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.post(
      Uri.parse('$_apiUrl/recommendations'), // Убрано /generate
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
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.get(
      Uri.parse('$_apiUrl/recommendations?page=$page&limit=$limit'),
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
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.patch(
      Uri.parse('$_apiUrl/recommendations/$recommendationId/favorite'),
      body: jsonEncode({'is_favorite': isFavorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }
}