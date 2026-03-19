import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../domain/entities/catalog_entity.dart';

/// Сервис для работы с API каталога одежды
///
/// Эндпоинты:
/// - GET /api/catalog/items — получить вещи из каталога
/// - GET /api/catalog/search — поиск с фильтрами
/// - GET /api/catalog/categories — категории
/// - GET /api/catalog/items/{id} — получить конкретную вещь
/// - GET /api/catalog/items/{id}/similar — похожие вещи
class CatalogApiService {
  final ApiClient _apiClient;

  CatalogApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Получить список вещей из каталога с поиском и фильтрами
  ///
  /// [query] — поисковый запрос
  /// [category] — фильтр по категории
  /// [subcategory] — фильтр по подкатегории
  /// [style] — фильтр по стилю
  /// [color] — фильтр по цвету
  /// [page] — номер страницы (по умолчанию 1)
  /// [limit] — количество на странице (по умолчанию 20)
  Future<CatalogListResponse> getCatalogItems({
    String? query,
    String? category,
    String? subcategory,
    String? style,
    String? color,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};

    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    if (subcategory != null && subcategory.isNotEmpty) {
      params['subcategory'] = subcategory;
    }
    if (style != null && style.isNotEmpty) {
      params['style'] = style;
    }
    if (color != null && color.isNotEmpty) {
      params['color'] = color;
    }

    final response = await _apiClient.get(
      '/api/catalog/search',
      params: params,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemsData = data['items'] as List<dynamic>? ?? [];
      final pagination = data['pagination'] as Map<String, dynamic>?;

      final items =
          itemsData
              .map(
                (item) => CatalogEntity.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      return CatalogListResponse(
        items: items,
        total: pagination?['total'] as int? ?? items.length,
        page: pagination?['page'] as int? ?? page,
        limit: pagination?['limit'] as int? ?? limit,
      );
    } else {
      throw CatalogApiException(
        'Ошибка получения каталога: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Получить категории каталога
  Future<CatalogCategoriesResponse> getCategories() async {
    final response = await _apiClient.get('/api/catalog/categories');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      return CatalogCategoriesResponse.fromJson(data);
    } else {
      throw CatalogApiException(
        'Ошибка получения категорий: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Получить конкретную вещь из каталога по ID
  Future<CatalogEntity> getCatalogItem(String itemId) async {
    final response = await _apiClient.get('/api/catalog/items/$itemId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemData = data['item'] as Map<String, dynamic>? ?? data;
      return CatalogEntity.fromJson(itemData);
    } else {
      throw CatalogApiException(
        'Ошибка получения вещи: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Получить похожие вещи
  Future<List<CatalogEntity>> getSimilarItems(
    String itemId, {
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/catalog/items/$itemId/similar',
      params: {'limit': limit},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.data as String) as Map<String, dynamic>;
      final itemsData = data['items'] as List<dynamic>? ?? [];
      return itemsData
          .map((item) => CatalogEntity.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw CatalogApiException(
        'Ошибка получения похожих вещей: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

/// Ответ API со списком вещей каталога
class CatalogListResponse {
  final List<CatalogEntity> items;
  final int total;
  final int page;
  final int limit;

  CatalogListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });
}

/// Ответ API с категориями
class CatalogCategoriesResponse {
  final List<CatalogCategory> categories;

  CatalogCategoriesResponse({required this.categories});

  factory CatalogCategoriesResponse.fromJson(Map<String, dynamic> json) {
    final categoriesData = json['categories'] as List<dynamic>? ?? [];
    return CatalogCategoriesResponse(
      categories:
          categoriesData
              .map(
                (cat) => CatalogCategory.fromJson(cat as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

/// Категория каталога
class CatalogCategory {
  final String name;
  final String displayName;
  final String emoji;
  final int itemCount;
  final List<String> subcategories;

  CatalogCategory({
    required this.name,
    required this.displayName,
    required this.emoji,
    required this.itemCount,
    required this.subcategories,
  });

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    final subcatsData = json['subcategories'] as List<dynamic>? ?? [];
    return CatalogCategory(
      name: json['name'] as String? ?? '',
      displayName:
          json['display_name'] as String? ?? json['name'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📦',
      itemCount: json['item_count'] as int? ?? 0,
      subcategories: subcatsData.map((e) => e as String).toList(),
    );
  }
}

/// Исключение API каталога
class CatalogApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const CatalogApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() {
    if (statusCode != null) {
      return 'CatalogApiException[$statusCode]: $message';
    }
    return 'CatalogApiException: $message';
  }
}
