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

  WardrobeService(
      {required this.apiConfig,
      required this.authStorage,
      http.Client? httpClient})
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

  Future<(List<WardrobeItem>, int)> list(
      {required int page, required int limit}) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.get(
      Uri.parse('$_apiUrl/wardrobe?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      // Используем правильные ключи: 'items' и 'pagination.total'
      final List<dynamic> listJson = json['items'] as List;
      final List<WardrobeItem> items = listJson
          .whereType<Map>()
          .map((e) => WardrobeItem.fromJson(e.cast<String, dynamic>()))
          .toList();
      // Проверяем оба варианта: 'total' и 'pagination.total'
      final int total = json.containsKey('pagination')
          ? json['pagination']['total'] as int
          : json['total'] as int;
      return (items, total);
    } else {
      throw Exception('Failed to list wardrobe: ${response.statusCode}');
    }
  }

  Future<List<WardrobeItem>> fetchAll() async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.get(
      Uri.parse('$_apiUrl/wardrobe'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> listJson = json['items'] as List;
      return listJson
          .whereType<Map>()
          .map((e) => WardrobeItem.fromJson(e.cast<String, dynamic>()))
          .toList();
    } else {
      throw Exception('Failed to load wardrobe: ${response.statusCode}');
    }
  }

  Future<WardrobeItem> create(WardrobeCreateRequest request) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.post(
      Uri.parse('$_apiUrl/wardrobe'),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return WardrobeItem.fromJson(
          json['wardrobe_item'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create wardrobe item: ${response.statusCode}');
    }
  }

  Future<WardrobeItem> update(String id, WardrobeUpdateRequest request) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.put(
      Uri.parse('$_apiUrl/wardrobe/$id'),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return WardrobeItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update wardrobe item: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.delete(
      Uri.parse('$_apiUrl/wardrobe/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete wardrobe item: ${response.statusCode}');
    }
  }

  Future<WardrobeItem> getById(String id) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.get(
      Uri.parse('$_apiUrl/wardrobe/$id'),
    );

    if (response.statusCode == 200) {
      return WardrobeItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get wardrobe item: ${response.statusCode}');
    }
  }

  Future<void> setFavorite(String id, bool favorite) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.post(
      Uri.parse('$_apiUrl/wardrobe/$id/favorite'),
      body: jsonEncode({'is_favorite': favorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite: ${response.statusCode}');
    }
  }

  Future<void> setArchived(String id, bool archived) async {
    final client = AuthenticatedHttpClient(httpClient, apiConfig, authStorage);
    final response = await client.post(
      Uri.parse('$_apiUrl/wardrobe/$id/archive'),
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

  // Методы для интеграции с рекомендациями
  Future<void> syncFromServer() async {
    try {
      final items = await fetchAll();
      await upsertMany(items);
    } catch (e) {
      // Логируем ошибку синхронизации
      // print('Wardrobe sync error: $e'); // В реальном приложении используйте proper logging
      rethrow;
    }
  }

  Future<void> upsertMany(List<WardrobeItem> items) async {
    // В реальном приложении этот метод будет обновлять локальную базу
    // Пока что просто вызываем update для каждого элемента
    for (final item in items) {
      try {
        await update(
            item.id,
            WardrobeUpdateRequest(
              name: item.name,
              category: item.category,
              subcategory: item.subcategory,
              style: item.style,
              iconEmoji: item.iconEmoji,
            ));
      } catch (e) {
        // Игнорируем ошибки обновления отдельных элементов
      }
    }
  }

  Future<List<WardrobeItem>> getItemsForRecommendation(
      {String? category, String? season, String? weather}) async {
    // Получаем все элементы гардероба
    final allItems = await fetchAll();

    // Фильтруем по заданным критериям
    return allItems.where((item) {
      bool matches = true;

      if (category != null && item.category != category) {
        matches = false;
      }

      if (season != null && item.season != season) {
        matches = false;
      }

      // Погодные фильтры
      if (weather != null) {
        if (weather.contains('rain') && !item.rainOk) {
          matches = false;
        }
        if (weather.contains('snow') && !item.snowOk) {
          matches = false;
        }
        if (weather.contains('wind') && !item.windOk) {
          matches = false;
        }
      }

      return matches;
    }).toList();
  }
}
