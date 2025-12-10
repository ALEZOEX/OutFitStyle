import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  final String _baseUrl; // Ожидаем что-то вроде http://localhost:8080/api/v1
  final Map<String, String> _headers;

  ApiService({
    required String baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl,
        _client = client ?? http.Client(),
        _headers = const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

  // --- РЕКОМЕНДАЦИИ / ПОГОДА ---

  Future<Recommendation> getRecommendations(
      String city, {
        required int userId,
        String source = 'mixed',
      }) async {
    final uri = _buildUri(
      '/recommendations',
      {
        'city': city,
        'user_id': userId.toString(),
        'source': source,
      },
    );
    final data = await _get(uri);

    final map = _ensureMapResponse(
      data: data,
      uri: uri,
      operation: 'получении рекомендаций',
      statusCode: 200,
    );

    return Recommendation.fromJson(map);
  }

  Future<WeatherData> getWeather(String city) async {
    final uri = _buildUri('/weather', {'city': city});
    final data = await _get(uri);

    final map = _ensureMapResponse(
      data: data,
      uri: uri,
      operation: 'получении данных о погоде',
      statusCode: 200,
    );

    return WeatherData.fromJson(map);
  }

  // --- ПРОФИЛЬ ПОЛЬЗОВАТЕЛЯ ---

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    // сервер: GET /api/v1/users/{id}/profile
    final uri = _buildUri('/users/$userId/profile');
    final data = await _get(uri);

    final map = _ensureMapResponse(
      data: data,
      uri: uri,
      operation: 'получении профиля пользователя',
      statusCode: 200,
    );

    return map;
  }

  // --- ИЗБРАННОЕ ---

  /// Список избранных рекомендаций пользователя.
  ///
  /// сервер: GET /api/v1/users/{user_id}/favorites
  /// ответ: { "favorites": [...], "count": N } или просто [... ]
  Future<List<FavoriteOutfit>> getFavorites({required int userId}) async {
    final uri = _buildUri('/users/$userId/favorites');
    final data = await _get(uri);

    if (data is Map<String, dynamic>) {
      final favorites = data['favorites'];
      if (favorites is List) {
        return favorites
            .whereType<Map<String, dynamic>>()
            .map(FavoriteOutfit.fromJson)
            .toList();
      }
      return [];
    }

    // fallback на старый формат (чистый массив)
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(FavoriteOutfit.fromJson)
          .toList();
    }

    return [];
  }

  /// Добавить рекомендацию в избранное.
  ///
  /// сервер: POST /api/v1/recommendations/{id}/favorite
  /// body: { "user_id": int }
  Future<void> addFavorite({
    required int userId,
    required int recommendationId,
  }) async {
    final uri = _buildUri('/recommendations/$recommendationId/favorite');
    final body = json.encode({'user_id': userId});
    await _post(uri, body: body, expectedStatusCode: 200);
  }

  /// Удалить рекомендацию из избранного.
  ///
  /// сервер: DELETE /api/v1/recommendations/{id}/favorite
  /// body: { "user_id": int }
  Future<void> removeFavorite({
    required int userId,
    required int recommendationId,
  }) async {
    final uri = _buildUri('/recommendations/$recommendationId/favorite');
    final body = json.encode({'user_id': userId});
    await _delete(uri, body: body, expectedStatusCode: 200);
  }

  // --- ИСТОРИЯ ---

  /// История рекомендаций пользователя.
  ///
  /// сервер: GET /api/v1/recommendations/history?user_id=...&limit=...
  /// ответ: { "history": [...], "count": N } или просто [...]
  Future<List<HistoryItem>> getRecommendationHistory({
    required int userId,
    int limit = 10,
  }) async {
    final uri = _buildUri(
      '/recommendations/history',
      {
        'user_id': userId.toString(),
        'limit': limit.toString(),
      },
    );
    final data = await _get(uri);

    if (data is Map<String, dynamic>) {
      final historyData = data['history'];
      if (historyData is List) {
        return historyData
            .whereType<Map<String, dynamic>>()
            .map(HistoryItem.fromJson)
            .toList();
      }
      return [];
    }

    // fallback, если вернули просто массив
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(HistoryItem.fromJson)
          .toList();
    }

    return [];
  }

  // --- ГАРДЕРОБ ---

  /// Получить гардероб пользователя.
  ///
  /// сервер: предположительно GET /api/v1/wardrobe?user_id=...
  /// ответ: { "upper": [...], "lower": [...], ... }
  Future<Map<String, List<WardrobeItem>>> getWardrobe({
    required int userId,
  }) async {
    final uri = _buildUri('/wardrobe', {'user_id': userId.toString()});
    final data = await _get(uri);

    final Map<String, List<WardrobeItem>> wardrobe = {};

    if (data is Map<String, dynamic>) {
      data.forEach((category, items) {
        if (items is List) {
          wardrobe[category] = items
              .whereType<Map<String, dynamic>>()
              .map(WardrobeItem.fromJson)
              .toList();
        }
      });
    }

    return wardrobe;
  }

  Future<WardrobeItem> addWardrobeItem({
    required int userId,
    required String name,
    required String category,
    required String icon,
  }) async {
    final uri = _buildUri('/wardrobe');
    final body = json.encode({
      'user_id': userId,
      'name': name,
      'category': category,
      'icon': icon,
    });
    final raw =
    await _post(uri, body: body, expectedStatusCode: 201);
    final map = _ensureMapResponse(
      data: raw,
      uri: uri,
      operation: 'добавлении предмета гардероба',
      statusCode: 201,
    );
    return WardrobeItem.fromJson(map);
  }

  Future<void> deleteWardrobeItem(int itemId) async {
    final uri = _buildUri('/wardrobe/$itemId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ПЛАНИРОВЩИК ---

  /// Получить планы нарядов пользователя.
  ///
  /// сервер: GET /api/v1/users/{user_id}/outfit-plans
  /// ответ: { "plans": [...], "count": N } или просто [...]
  Future<List<OutfitPlan>> getOutfitPlans({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{};
    if (startDate != null) {
      query['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      query['end_date'] = endDate.toIso8601String();
    }

    final uri = _buildUri('/users/$userId/outfit-plans', query);
    final data = await _get(uri);

    List<dynamic> rawList;

    if (data is Map<String, dynamic>) {
      rawList = data['plans'] as List<dynamic>? ?? const [];
    } else if (data is List) {
      rawList = data;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(OutfitPlan.fromJson)
        .toList();
  }

  Future<OutfitPlan> createOutfitPlan({
    required int userId,
    required DateTime date,
    required List<int> itemIds,
    String? notes,
  }) async {
    final uri = _buildUri('/users/$userId/outfit-plans');
    final body = json.encode({
      'date': date.toIso8601String().substring(0, 10),
      'item_ids': itemIds,
      'notes': notes,
    });
    final raw =
    await _post(uri, body: body, expectedStatusCode: 201);
    final map = _ensureMapResponse(
      data: raw,
      uri: uri,
      operation: 'создании плана наряда',
      statusCode: 201,
    );
    return OutfitPlan.fromJson(map);
  }

  Future<void> deleteOutfitPlan(int userId, int planId) async {
    final uri = _buildUri('/users/$userId/outfit-plans/$planId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- ДОСТИЖЕНИЯ ---

  /// Достижения пользователя.
  ///
  /// текущий путь зависит от бэка; оставляю как было (achievements?user_id=)
  Future<List<Achievement>> getAchievements({required int userId}) async {
    final uri = _buildUri('/achievements', {'user_id': userId.toString()});
    final data = await _get(uri);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Achievement.fromJson)
          .toList();
    }

    return [];
  }

  // --- SHOPPING WISHLIST ---

  Future<List<ShoppingItem>> getShoppingWishlist({
    required int userId,
  }) async {
    final uri = _buildUri('/users/$userId/shopping-wishlist');
    final data = await _get(uri);

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ShoppingItem.fromJson)
          .toList();
    }

    return [];
  }

  Future<ShoppingItem> addShoppingItem({
    required int userId,
    required String itemName,
    required double price,
    required String imageUrl,
    required String purchaseLink,
  }) async {
    final uri = _buildUri('/users/$userId/shopping-wishlist');
    final body = json.encode({
      'item_name': itemName,
      'price': price,
      'image_url': imageUrl,
      'purchase_link': purchaseLink,
    });
    final raw =
    await _post(uri, body: body, expectedStatusCode: 201);
    final map = _ensureMapResponse(
      data: raw,
      uri: uri,
      operation: 'добавлении товара в wishlist',
      statusCode: 201,
    );
    return ShoppingItem.fromJson(map);
  }

  Future<void> removeShoppingItem({
    required int userId,
    required int itemId,
  }) async {
    final uri = _buildUri('/users/$userId/shopping-wishlist/$itemId');
    await _delete(uri, expectedStatusCode: 204);
  }

  // --- РЕЙТИНГИ ---

  /// Оценка рекомендации.
  ///
  /// сервер: POST /api/v1/recommendations/{id}/rate
  /// body: { "user_id": int, "rating": 1..5, "feedback": string }
  Future<bool> submitRating({
    required int userId,
    required int recommendationId,
    required int rating,
    String? feedback,
  }) async {
    final uri = _buildUri('/recommendations/$recommendationId/rate');
    final body = json.encode({
      'user_id': userId,
      'rating': rating,
      'feedback': feedback,
    });

    await _post(uri, body: body, expectedStatusCode: 200);
    return true;
  }

  // --- БАЗОВЫЕ HTTP МЕТОДЫ ---

  Future<dynamic> _get(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(Duration(seconds: AppConfig.requestTimeout));
      return _processResponse(response);
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on SocketException catch (e) {
      throw NetworkException('Проблема с соединением: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    } catch (e) {
      throw NetworkException('Неизвестная сетевая ошибка: $e');
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
          .timeout(Duration(seconds: AppConfig.requestTimeout));
      return _processResponse(
        response,
        expectedStatusCode: expectedStatusCode,
      );
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on SocketException catch (e) {
      throw NetworkException('Проблема с соединением: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    } catch (e) {
      throw NetworkException('Неизвестная сетевая ошибка: $e');
    }
  }

  Future<void> _delete(
      Uri uri, {
        dynamic body,
        int expectedStatusCode = 204,
      }) async {
    try {
      final response = await _client
          .delete(uri, headers: _headers, body: body)
          .timeout(Duration(seconds: AppConfig.requestTimeout));
      if (response.statusCode != expectedStatusCode) {
        throw _handleError(response);
      }
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on SocketException catch (e) {
      throw NetworkException('Проблема с соединением: ${e.message}');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    } catch (e) {
      throw NetworkException('Неизвестная сетевая ошибка: $e');
    }
  }

  dynamic _processResponse(
      http.Response response, {
        int expectedStatusCode = 200,
      }) {
    if (response.statusCode != expectedStatusCode) {
      throw _handleError(response);
    }

    if (response.body.isEmpty) {
      return null;
    }

    final rawBody = utf8.decode(response.bodyBytes);
    try {
      return json.decode(rawBody);
    } catch (_) {
      final path = response.request?.url.path ?? '';
      throw ApiServiceException(
        'Ошибка разбора ответа сервера',
        response.statusCode,
        path,
      );
    }
  }

  ApiException _handleError(http.Response response) {
    String message = 'Неизвестная ошибка сервера';
    final path = response.request?.url.path ?? '';

    if (response.body.isNotEmpty) {
      try {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (body is Map<String, dynamic>) {
          message = body['error']?.toString() ??
              body['message']?.toString() ??
              message;
        } else {
          message = utf8.decode(response.bodyBytes).trim();
        }
      } catch (_) {
        message = utf8.decode(response.bodyBytes).trim();
      }
    }

    final lowerMsg = message.toLowerCase();

    // Считаем сессию истёкшей / битой, если:
    // - 401/403
    // - 404 и это профиль/пользователь
    final isAuthError =
        response.statusCode == 401 ||
            response.statusCode == 403 ||
            (response.statusCode == 404 &&
                (path.contains('/users/') ||
                    lowerMsg.contains('user not found') ||
                    lowerMsg.contains('profile not found')));

    if (isAuthError) {
      return AuthExpiredException(message);
    }

    return ApiServiceException(message, response.statusCode, path);
  }

  /// Собираем Uri на основе baseUrl (включающего /api/v1) и относительного path.
  ///
  /// Пример:
  ///   baseUrl: http://localhost:8080/api/v1
  ///   path:    /recommendations
  ///   → http://localhost:8080/api/v1/recommendations
  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final base = Uri.parse(_baseUrl); // может быть с путём (/api/v1)
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final relPath = path.startsWith('/') ? path : '/$path';
    final fullPath = '$basePath$relPath';

    return base.replace(
      path: fullPath,
      queryParameters: (queryParams?.isNotEmpty ?? false) ? queryParams : null,
    );
  }

  /// Закрыть http.Client, если сервис больше не нужен.
  void dispose() {
    _client.close();
  }

  // Вспомогательные методы для произвольных URL
  // Теперь используют те же таймауты и обработку ошибок, что и основной код.

  Future<dynamic> get(String url) async {
    final uri = Uri.parse(url);
    return _get(uri);
  }

  Future<dynamic> post(String url, dynamic body) async {
    final uri = Uri.parse(url);
    final encodedBody = body is String ? body : json.encode(body);
    return _post(uri, body: encodedBody, expectedStatusCode: 200);
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ УТИЛИТЫ ---

  Map<String, dynamic> _ensureMapResponse({
    required dynamic data,
    required Uri uri,
    required String operation,
    required int statusCode,
  }) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw ApiServiceException(
      'Неожиданный формат ответа сервера при $operation',
      statusCode,
      uri.path,
    );
  }
}