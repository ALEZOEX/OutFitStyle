import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../exceptions/api_exceptions.dart';
import '../models/achievement.dart';
import '../models/favorite.dart';
import '../models/history.dart';
import '../models/outfit_plan.dart';
import '../models/recommendation.dart';
import '../models/user_wardrobe.dart';
import '../models/shopping_item.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final Map<String, String> _headers;

  // Используем Singleton, чтобы экземпляр был один на все приложение
  static final ApiService _instance = ApiService._internal();

  // Исправлен синтаксис фабричного конструктора
  factory ApiService({http.Client? client}) {
    if (client != null) {
      return ApiService._internal(client: client);
    }
    return _instance;
  }

  ApiService._internal({http.Client? client})
      : _client = client ?? http.Client(),
        _headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        };

  // --- ОСНОВНЫЕ МЕТОДЫ ---

  Future<Recommendation> getRecommendations(String city,
      {int userId = 1}) async {
    final uri = _buildUri(
        '/api/recommend', {'city': city, 'user_id': userId.toString()});
    final response = await _get(uri);
    return Recommendation.fromJson(response);
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final uri = _buildUri('/api/users/profile', {'user_id': userId.toString()});
    return await _get(uri);
  }

  // --- ИЗБРАННОЕ ---

  Future<List<FavoriteOutfit>> getFavorites({required int userId}) async {
    final uri = _buildUri('/api/favorites', {'user_id': userId.toString()});
    final List<dynamic> data = await _get(uri);
    return data.map((json) => FavoriteOutfit.fromJson(json)).toList();
  }

  Future<void> addFavorite(int userId, int recommendationId) async {
    final uri = _buildUri('/api/favorites');
    final body =
        json.encode({'user_id': userId, 'recommendation_id': recommendationId});
    await _post(uri, body: body, expectedStatusCode: 201);
  }

  Future<void> deleteFavorite(int favoriteId) async {
    final uri = _buildUri('/api/favorites/$favoriteId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ИСТОРИЯ ---

  Future<List<HistoryItem>> getRecommendationHistory(
      {required int userId}) async {
    final uri = _buildUri(
        '/api/recommendations/history', {'user_id': userId.toString()});
    final data = await _get(uri);
    // Сервер возвращает объект {'history': [...]}, извлекаем сам список
    final List<dynamic> historyData = data['history'] ?? [];
    return historyData.map((json) => HistoryItem.fromJson(json)).toList();
  }

  // --- ГАРДЕРОБ ---

  Future<Map<String, List<WardrobeItem>>> getWardrobe(
      {required int userId}) async {
    final uri = _buildUri('/api/wardrobe', {'user_id': userId.toString()});
    final Map<String, dynamic> data = await _get(uri);
    final Map<String, List<WardrobeItem>> wardrobe = {};
    data.forEach((category, items) {
      if (items is List) {
        wardrobe[category] =
            items.map((item) => WardrobeItem.fromJson(item)).toList();
      }
    });
    return wardrobe;
  }

  Future<WardrobeItem> addWardrobeItem({
    required int userId,
    required String name,
    required String category,
    required String icon,
  }) async {
    final uri = _buildUri('/api/wardrobe');
    final body = json.encode({
      'user_id': userId,
      'name': name,
      'category': category,
      'icon': icon,
    });
    final response = await _post(uri, body: body, expectedStatusCode: 201);
    return WardrobeItem.fromJson(response);
  }

  Future<void> deleteWardrobeItem(int itemId) async {
    final uri = _buildUri('/api/wardrobe/$itemId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ПЛАНИРОВЩИК ---

  Future<List<OutfitPlan>> getOutfitPlans(
      {required int userId, DateTime? startDate, DateTime? endDate}) async {
    final query = <String, String>{};
    if (startDate != null) query['start_date'] = startDate.toIso8601String();
    if (endDate != null) query['end_date'] = endDate.toIso8601String();

    final uri = _buildUri('/api/users/$userId/outfit-plans', query);
    final List<dynamic> data = await _get(uri);
    return data.map((json) => OutfitPlan.fromJson(json)).toList();
  }

  Future<OutfitPlan> createOutfitPlan({
    required int userId,
    required DateTime date,
    required List<int> itemIds,
    String? notes,
  }) async {
    final uri = _buildUri('/api/users/$userId/outfit-plans');
    final body = json.encode({
      'date': date.toIso8601String().substring(0, 10),
      'item_ids': itemIds,
      'notes': notes,
    });
    final response = await _post(uri, body: body, expectedStatusCode: 201);
    return OutfitPlan.fromJson(response);
  }

  Future<void> deleteOutfitPlan(int userId, int planId) async {
    final uri = _buildUri('/api/users/$userId/outfit-plans/$planId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ДОСТИЖЕНИЯ ---

  Future<List<Achievement>> getAchievements({required int userId}) async {
    final uri = _buildUri('/api/achievements', {'user_id': userId.toString()});
    final List<dynamic> data = await _get(uri);
    return data.map((json) => Achievement.fromJson(json)).toList();
  }

  // --- SHOPPING WISHLIST ---

  Future<List<ShoppingItem>> getShoppingWishlist({required int userId}) async {
    final uri = _buildUri('/api/users/$userId/shopping-wishlist');
    final List<dynamic> data = await _get(uri);
    return data.map((json) => ShoppingItem.fromJson(json)).toList();
  }

  Future<ShoppingItem> addShoppingItem({
    required int userId,
    required String itemName,
    required double price,
    required String imageUrl,
    required String purchaseLink,
  }) async {
    final uri = _buildUri('/api/users/$userId/shopping-wishlist');
    final body = json.encode({
      'item_name': itemName,
      'price': price,
      'image_url': imageUrl,
      'purchase_link': purchaseLink,
    });
    final response = await _post(uri, body: body, expectedStatusCode: 201);
    return ShoppingItem.fromJson(response as Map<String, dynamic>);
  }

  Future<void> removeShoppingItem({
    required int userId,
    required int itemId,
  }) async {
    final uri = _buildUri('/api/users/$userId/shopping-wishlist/$itemId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- БАЗОВЫЕ HTTP МЕТОДЫ (приватные) ---

  Future<dynamic> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    }
  }

  Future<dynamic> _post(Uri uri,
      {dynamic body, int expectedStatusCode = 200}) async {
    try {
      final response = await _client
          .post(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 15));
      return _processResponse(response,
          expectedStatusCode: expectedStatusCode);
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    }
  }

  Future<void> _delete(Uri uri, {int expectedStatusCode = 204}) async {
    try {
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != expectedStatusCode) {
        throw _handleError(response);
      }
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    }
  }

  dynamic _processResponse(http.Response response,
      {int expectedStatusCode = 200}) {
    if (response.statusCode == expectedStatusCode) {
      if (response.body.isEmpty) {
        return null; // Для ответов без тела, как DELETE
      }
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw _handleError(response);
    }
  }

  ApiException _handleError(http.Response response) {
    String message = 'Неизвестная ошибка сервера';
    if (response.body.isNotEmpty) {
      try {
        final body = json.decode(utf8.decode(response.bodyBytes));
        message = body['error'] ??
            body['message'] ??
            'Сервер вернул ошибку без описания.';
      } catch (_) {
        message = utf8.decode(response.bodyBytes).trim();
      }
    }
    return ApiServiceException(
        message, response.statusCode, response.request?.url.path ?? '');
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final url = _baseUrl;
    if (url.startsWith('https')) {
      return Uri.https(url.replaceFirst('https://', ''), path, queryParams);
    } else {
      final authority = url.replaceFirst('http://', '');
      return Uri.http(authority, path, queryParams);
    }
  }

  /// Отправляет оценку пользователя на сервер
  Future<bool> submitRating({
    required int userId,
    required int recommendationId,
    required int rating,
    String? feedback,
  }) async {
    final uri = _buildUri('/api/ratings');
    final body = json.encode({
      'user_id': userId,
      'recommendation_id': recommendationId,
      'rating': rating,
      'feedback': feedback,
    });
    
    try {
      await _post(uri, body: body, expectedStatusCode: 201);
      return true;
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  /// Performs a GET request to the specified URL
  Future<dynamic> get(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  /// Performs a POST request to the specified URL with the provided body
  Future<dynamic> post(String url, dynamic body) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}