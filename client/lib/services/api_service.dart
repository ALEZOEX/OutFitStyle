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
import '../models/weather_data.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl = AppConfig.apiBaseUrl;
  final Map<String, String> _headers;

  static const String _apiPrefix = '/api/v1';

  // Singleton
  static final ApiService _instance = ApiService._internal();

  factory ApiService({http.Client? client}) {
    if (client != null) {
      return ApiService._internal(client: client);
    }
    return _instance;
  }

  ApiService._internal({http.Client? client})
      : _client = client ?? http.Client(),
        _headers = const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  // --- РЕКОМЕНДАЦИИ / ПОГОДА ---

  Future<Recommendation> getRecommendations(String city,
      {int userId = 1}) async {
    final uri = _buildUri(
      '$_apiPrefix/recommendations',
      {'city': city, 'user_id': userId.toString()},
    );
    final response = await _get(uri);
    return Recommendation.fromJson(response);
  }

  Future<WeatherData> getWeather(String city) async {
    final uri = _buildUri('$_apiPrefix/weather', {'city': city});
    final data = await _get(uri);
    return WeatherData.fromJson(data);
  }

  // --- ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ ---

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    // сервер: GET /api/v1/users/{id}/profile
    final uri = _buildUri('$_apiPrefix/users/$userId/profile');
    return await _get(uri);
  }

  // --- ИЗБРАННОЕ ---

  Future<List<FavoriteOutfit>> getFavorites({required int userId}) async {
    final uri = _buildUri(
      '$_apiPrefix/favorites',
      {'user_id': userId.toString()},
    );
    final List<dynamic> data = await _get(uri);
    return data.map((json) => FavoriteOutfit.fromJson(json)).toList();
  }

  Future<void> addFavorite(int userId, int recommendationId) async {
    final uri = _buildUri('$_apiPrefix/favorites');
    final body = json.encode({
      'user_id': userId,
      'recommendation_id': recommendationId,
    });
    await _post(uri, body: body, expectedStatusCode: 201);
  }

  Future<void> deleteFavorite(int favoriteId) async {
    final uri = _buildUri('$_apiPrefix/favorites/$favoriteId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ИСТОРИЯ ---

  Future<List<HistoryItem>> getRecommendationHistory(
      {required int userId}) async {
    final uri = _buildUri(
      '$_apiPrefix/recommendations/history',
      {'user_id': userId.toString()},
    );
    final data = await _get(uri);
    final List<dynamic> historyData = data['history'] ?? [];
    return historyData.map((json) => HistoryItem.fromJson(json)).toList();
  }

  // --- ГАРДЕРОБ ---

  Future<Map<String, List<WardrobeItem>>> getWardrobe(
      {required int userId}) async {
    final uri = _buildUri(
      '$_apiPrefix/wardrobe',
      {'user_id': userId.toString()},
    );
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
    final uri = _buildUri('$_apiPrefix/wardrobe');
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
    final uri = _buildUri('$_apiPrefix/wardrobe/$itemId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ПЛАНИРОВЩИК ---

  Future<List<OutfitPlan>> getOutfitPlans({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{};
    if (startDate != null) query['start_date'] = startDate.toIso8601String();
    if (endDate != null) query['end_date'] = endDate.toIso8601String();

    // сервер: GET /api/v1/users/{id}/outfit-plans
    final uri = _buildUri('$_apiPrefix/users/$userId/outfit-plans', query);
    final List<dynamic> data = await _get(uri);
    return data.map((json) => OutfitPlan.fromJson(json)).toList();
  }

  Future<OutfitPlan> createOutfitPlan({
    required int userId,
    required DateTime date,
    required List<int> itemIds,
    String? notes,
  }) async {
    final uri = _buildUri('$_apiPrefix/users/$userId/outfit-plans');
    final body = json.encode({
      'date': date.toIso8601String().substring(0, 10),
      'item_ids': itemIds,
      'notes': notes,
    });
    final response = await _post(uri, body: body, expectedStatusCode: 201);
    return OutfitPlan.fromJson(response);
  }

  Future<void> deleteOutfitPlan(int userId, int planId) async {
    final uri = _buildUri('$_apiPrefix/users/$userId/outfit-plans/$planId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ДОСТИЖЕНИЯ ---

  Future<List<Achievement>> getAchievements({required int userId}) async {
    final uri = _buildUri(
      '$_apiPrefix/achievements',
      {'user_id': userId.toString()},
    );
    final List<dynamic> data = await _get(uri);
    return data.map((json) => Achievement.fromJson(json)).toList();
  }

  // --- SHOPPING WISHLIST ---

  Future<List<ShoppingItem>> getShoppingWishlist({required int userId}) async {
    final uri =
    _buildUri('$_apiPrefix/users/$userId/shopping-wishlist');
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
    final uri =
    _buildUri('$_apiPrefix/users/$userId/shopping-wishlist');
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
    final uri = _buildUri(
        '$_apiPrefix/users/$userId/shopping-wishlist/$itemId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- РЕЙТИНГИ ---

  Future<bool> submitRating({
    required int userId,
    required int recommendationId,
    required int rating,
    String? feedback,
  }) async {
    final uri = _buildUri('$_apiPrefix/ratings');
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

  // --- БАЗОВЫЕ HTTP МЕТОДЫ ---

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

  Future<dynamic> _post(
      Uri uri, {
        dynamic body,
        int expectedStatusCode = 200,
      }) async {
    try {
      final response = await _client
          .post(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 15));
      return _processResponse(
        response,
        expectedStatusCode: expectedStatusCode,
      );
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    }
  }

  Future<void> _delete(
      Uri uri, {
        int expectedStatusCode = 204,
      }) async {
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

  dynamic _processResponse(
      http.Response response, {
        int expectedStatusCode = 200,
      }) {
    if (response.statusCode == expectedStatusCode) {
      if (response.body.isEmpty) {
        return null;
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
      message,
      response.statusCode,
      response.request?.url.path ?? '',
    );
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final url = _baseUrl;
    if (url.startsWith('https')) {
      return Uri.https(
        url.replaceFirst('https://', ''),
        path,
        queryParams,
      );
    } else {
      final authority = url.replaceFirst('http://', '');
      return Uri.http(authority, path, queryParams);
    }
  }

  // Простые GET/POST по произвольному URL (если ещё нужны)
  Future<dynamic> get(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

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