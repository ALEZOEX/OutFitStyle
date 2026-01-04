import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/wardrobe_models.dart';
import '../services/auth_storage.dart';
import 'http_client.dart';
import '../app/api/api_config.dart';

class WardrobeService {
  final ApiConfig apiConfig;
  final AuthStorage authStorage;
  final http.Client httpClient;

  WardrobeService({required this.apiConfig, required this.authStorage, http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  String get _apiUrl {
    // Убедимся, что baseUrl заканчивается на /api/v1
    if (!apiConfig.apiBase.endsWith('/api/v1')) {
      if (apiConfig.apiBase.endsWith('/')) {
        return apiConfig.apiBase + 'api/v1';
      } else {
        return apiConfig.apiBase + '/api/v1';
      }
    }
    return apiConfig.apiBase;
  }

  Future<(List<WardrobeItemResponse>, int)> list({required int page, required int limit}) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.get(
      Uri.parse('$_apiUrl/wardrobe?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Используем правильные ключи: 'items' и 'pagination.total'
      final List<dynamic> listJson = json['items'] as List;
      final List<WardrobeItemResponse> items = listJson
          .whereType<Map>()
          .map((e) => WardrobeItemResponse.fromJson(e.cast<String, dynamic>()))
          .toList();
      // Проверяем оба варианта: 'total' и 'pagination.total'
      final int total = json.containsKey('pagination') ? json['pagination']['total'] as int : json['total'] as int;
      return (items, total);
    } else {
      throw Exception('Failed to list wardrobe: ${response.statusCode}');
    }
  }

  Future<List<WardrobeItemResponse>> fetchAll() async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.get(
      Uri.parse('$_apiUrl/wardrobe'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => WardrobeItemResponse.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load wardrobe: ${response.statusCode}');
    }
  }

  Future<void> setFavorite(String id, bool favorite) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.patch(
      Uri.parse('$_apiUrl/wardrobe/$id/favorite'),
      body: jsonEncode({'is_favorite': favorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }

  Future<void> setArchived(String id, bool archived) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.patch(
      Uri.parse('$_apiUrl/wardrobe/$id/archived'),
      body: jsonEncode({'is_archived': archived}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update archived: ${response.statusCode}');
    }
  }

  Future<void> worn(String id) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.post(
      Uri.parse('$_apiUrl/wardrobe/$id/worn'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update worn count: ${response.statusCode}');
    }
  }
}