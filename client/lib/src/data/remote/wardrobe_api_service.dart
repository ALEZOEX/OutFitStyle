import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../../domain/entities/wardrobe_item.dart';
import '../../domain/entities/wardrobe_request_entities.dart';

/// Сервис для работы с API гардероба
///
/// Эндпоинты:
/// - GET /api/v1/wardrobe — получить все вещи
/// - POST /api/v1/wardrobe — добавить вещь
/// - PUT /api/v1/wardrobe/{id} — обновить вещь
/// - DELETE /api/v1/wardrobe/{id} — удалить вещь
class WardrobeApiService {
  final ApiClient _apiClient;

  WardrobeApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Получить список вещей гардероба
  ///
  /// [includeArchived] — включать архивированные вещи
  /// [category] — фильтр по категории
  /// [style] — фильтр по стилю
  /// [isFavorite] — фильтр по избранному
  /// [page] — номер страницы (по умолчанию 1)
  /// [limit] — количество на странице (по умолчанию 20)
  /// [search] — поисковый запрос
  Future<WardrobeListResponse> getWardrobeItems({
    bool includeArchived = false,
    String? category,
    String? style,
    bool? isFavorite,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'include_archived': includeArchived.toString(),
    };

    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    if (style != null && style.isNotEmpty) {
      params['style'] = style;
    }
    if (isFavorite != null) {
      params['is_favorite'] = isFavorite.toString();
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await _apiClient.get('/api/v1/wardrobe', params: params);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemsData = data['items'] as List<dynamic>? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>?;

      final items =
          itemsData
              .map(
                (item) => WardrobeItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      return WardrobeListResponse(
        items: items,
        total: pagination?['total'] as int? ?? items.length,
        page: pagination?['page'] as int? ?? page,
        limit: pagination?['limit'] as int? ?? limit,
      );
    } else {
      throw WardrobeApiException(
        'Ошибка получения гардероба: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Получить вещь по ID
  Future<WardrobeItem> getWardrobeItem(String id) async {
    final response = await _apiClient.get('/api/wardrobe/$id');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemData = data['item'] as Map<String, dynamic>? ?? data;
      return WardrobeItem.fromJson(itemData);
    } else {
      throw WardrobeApiException(
        'Ошибка получения вещи: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Создать новую вещь в гардеробе
  Future<WardrobeItem> createWardrobeItem(
    WardrobeItemCreateRequest request,
  ) async {
    final response = await _apiClient.post(
      '/api/v1/wardrobe',
      data: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemData =
          data['wardrobe_item'] as Map<String, dynamic>? ??
          data['item'] as Map<String, dynamic>? ??
          data;
      return WardrobeItem.fromJson(itemData);
    } else {
      final errorData = _parseError(response);
      throw WardrobeApiException(
        errorData['message'] ?? 'Ошибка создания вещи: ${response.statusCode}',
        statusCode: response.statusCode,
        details: errorData['details'],
      );
    }
  }

  /// Обновить вещь в гардеробе
  Future<WardrobeItem> updateWardrobeItem(
    String id,
    WardrobeItemUpdateRequest request,
  ) async {
    final response = await _apiClient.put(
      '/api/v1/wardrobe/$id',
      data: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemData =
          data['wardrobe_item'] as Map<String, dynamic>? ??
          data['item'] as Map<String, dynamic>? ??
          data;
      return WardrobeItem.fromJson(itemData);
    } else {
      final errorData = _parseError(response);
      throw WardrobeApiException(
        errorData['message'] ??
            'Ошибка обновления вещи: ${response.statusCode}',
        statusCode: response.statusCode,
        details: errorData['details'],
      );
    }
  }

  /// Удалить вещь из гардероба
  Future<void> deleteWardrobeItem(String id) async {
    final response = await _apiClient.delete('/api/wardrobe/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw WardrobeApiException(
        'Ошибка удаления вещи: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Добавить/удалить вещь из избранного
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final response = await _apiClient.post(
      '/api/wardrobe/$id/favorite',
      data: jsonEncode({'is_favorite': isFavorite}),
    );

    if (response.statusCode != 200) {
      throw WardrobeApiException(
        'Ошибка обновления избранного: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Архивировать/восстановить вещь
  Future<void> toggleArchive(String id, bool isArchived) async {
    final response = await _apiClient.post(
      '/api/wardrobe/$id/archive',
      data: jsonEncode({'is_archived': isArchived}),
    );

    if (response.statusCode != 200) {
      throw WardrobeApiException(
        'Ошибка архивирования: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Отметить вещь как использованную
  Future<WornResponse> markAsWorn(String id) async {
    final response = await _apiClient.post('/api/wardrobe/$id/worn');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      return WornResponse(
        wearCount: data['wear_count'] as int? ?? 0,
        lastWornAt:
            data['last_worn_at'] != null
                ? DateTime.tryParse(data['last_worn_at'] as String)
                : null,
      );
    } else {
      throw WardrobeApiException(
        'Ошибка отметки вещи: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Распарсить ошибку из ответа
  Map<String, dynamic> _parseError(Response response) {
    try {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>?;
      return data ?? {};
    } catch (_) {
      return {};
    }
  }
}

/// Ответ API со списком вещей
class WardrobeListResponse {
  final List<WardrobeItem> items;
  final int total;
  final int page;
  final int limit;

  WardrobeListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
}

/// Ответ API с информацией о использовании вещи
class WornResponse {
  final int wearCount;
  final DateTime? lastWornAt;

  WornResponse({required this.wearCount, this.lastWornAt});
}

/// Исключение API гардероба
class WardrobeApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const WardrobeApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'WardrobeApiException[$statusCode]: $message';
    }
    return 'WardrobeApiException: $message';
  }
}
