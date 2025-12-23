import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recommendation_models.dart';
import 'auth_storage.dart';

class RecommendationService {
  final String baseUrl;
  final AuthStorage authStorage;

  RecommendationService({required this.baseUrl, required this.authStorage});

  String get _apiUrl => baseUrl; // baseUrl уже содержит /api/v1

  Future<RecommendationRecord> createUsingProfile({required String occasion}) async {
    final token = await authStorage.getToken();
    final response = await http.post(
      Uri.parse('$_apiUrl/recommendations/generate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'occasion': occasion,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return RecommendationRecord.fromJson(json);
    } else {
      throw Exception('Failed to create recommendation: ${response.statusCode}');
    }
  }

  Future<(List<RecommendationRecord>, int)> list({required int page, required int limit}) async {
    final token = await authStorage.getToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/recommendations?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> listJson = json['items'] as List;
      final List<RecommendationRecord> items = listJson
          .map((e) => RecommendationRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      final int total = json['total'] as int;
      return (items, total);
    } else {
      throw Exception('Failed to list recommendations: ${response.statusCode}');
    }
  }

  Future<void> setFavorite({required String recommendationId, required bool isFavorite}) async {
    final token = await authStorage.getToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/recommendations/$recommendationId/favorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'favorite': isFavorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }
}