import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/wardrobe_models.dart';
import '../services/auth_storage.dart';

class WardrobeService {
  final String baseUrl;
  final AuthStorage authStorage;

  WardrobeService({required this.baseUrl, required this.authStorage});

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

  Future<(List<WardrobeItemResponse>, int)> list({required int page, required int limit}) async {
    final token = await authStorage.readAccessToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/wardrobe?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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
    final token = await authStorage.readAccessToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/wardrobe'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => WardrobeItemResponse.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load wardrobe: ${response.statusCode}');
    }
  }

  Future<void> setFavorite(String id, bool favorite) async {
    final token = await authStorage.readAccessToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/wardrobe/$id/favorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // Изменяем ключ с 'value' на 'is_favorite'
      body: jsonEncode({'is_favorite': favorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }

  Future<void> setArchived(String id, bool archived) async {
    final token = await authStorage.readAccessToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/wardrobe/$id/archived'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // Изменяем ключ с 'value' на 'is_archived'
      body: jsonEncode({'is_archived': archived}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update archived: ${response.statusCode}');
    }
  }

  Future<void> worn(String id) async {
    final token = await authStorage.readAccessToken();
    final response = await http.post(
      Uri.parse('$_apiUrl/wardrobe/$id/worn'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update worn count: ${response.statusCode}');
    }
  }
}