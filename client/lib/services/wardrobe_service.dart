import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/wardrobe_models.dart';
import 'auth_storage.dart';

class WardrobeService {
  final String baseUrl;
  final AuthStorage authStorage;

  WardrobeService({required this.baseUrl, required this.authStorage});

  String get _apiUrl => baseUrl; // baseUrl уже содержит /api/v1

  Future<List<WardrobeItemResponse>> fetchAll() async {
    final token = await authStorage.getToken();
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
    final token = await authStorage.getToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/wardrobe/$id/favorite'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'favorite': favorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }

  Future<void> setArchived(String id, bool archived) async {
    final token = await authStorage.getToken();
    final response = await http.patch(
      Uri.parse('$_apiUrl/wardrobe/$id/archived'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'archived': archived}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update archived: ${response.statusCode}');
    }
  }

  Future<void> worn(String id) async {
    final token = await authStorage.getToken();
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

  Future<(List<WardrobeItemResponse>, int)> list({required int page, required int limit}) async {
    final token = await authStorage.getToken();
    final response = await http.get(
      Uri.parse('$_apiUrl/wardrobe?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> listJson = json['items'] as List;
      final List<WardrobeItemResponse> items = listJson
          .map((e) => WardrobeItemResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      final int total = json['total'] as int;
      return (items, total);
    } else {
      throw Exception('Failed to list wardrobe items: ${response.statusCode}');
    }
  }
}