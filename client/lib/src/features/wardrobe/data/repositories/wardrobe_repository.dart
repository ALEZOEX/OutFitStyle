import '../../../core/api/api_client.dart';
import '../../entities/wardrobe_item.dart';

/// Репозиторий для работы с гардеробом пользователя
/// 
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/wardrobe - список вещей
/// - POST /api/v1/wardrobe - создание вещи
/// - GET /api/v1/wardrobe/{id} - получение вещи
/// - PUT /api/v1/wardrobe/{id} - обновление вещи
/// - DELETE /api/v1/wardrobe/{id} - удаление вещи
class WardrobeRepository {
  final ApiClient _apiClient;

  WardrobeRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Получить список вещей гардероба
  /// 
  /// [category] - фильтр по категории
  /// [color] - фильтр по цвету
  /// [season] - фильтр по сезону
  /// [style] - фильтр по стилю
  /// [isFavorite] - фильтр по избранному
  /// [page] - номер страницы
  /// [limit] - количество на странице
  /// [search] - поисковый запрос
  /// 
  /// Endpoint: GET /api/v1/wardrobe
  Future<WardrobeListResult> getWardrobeItems({
    String? category,
    String? color,
    String? season,
    String? style,
    bool? isFavorite,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }
      if (color != null && color.isNotEmpty) {
        params['color'] = color;
      }
      if (season != null && season.isNotEmpty) {
        params['season'] = season;
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
        final data = response.data as Map<String, dynamic>;
        final itemsData = data['items'] as List<dynamic>? ?? data['data'] as List<dynamic>? ?? [];
        final total = data['total'] as int? ?? 0;
        
        final items = itemsData
            .map((item) => WardrobeItem.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return WardrobeListResult(items: items, total: total);
      } else {
        throw WardrobeException('Ошибка получения гардероба: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка получения гардероба: $e');
    }
  }

  /// Получить вещь по ID
  /// 
  /// [id] - ID вещи
  /// 
  /// Endpoint: GET /api/v1/wardrobe/{id}
  Future<WardrobeItem> getWardrobeItem(String id) async {
    try {
      final response = await _apiClient.get('/api/v1/wardrobe/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final itemData = data['item'] as Map<String, dynamic>? ?? data;
        return WardrobeItem.fromJson(itemData);
      } else {
        throw WardrobeException('Ошибка получения вещи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка получения вещи: $e');
    }
  }

  /// Создать новую вещь в гардеробе
  /// 
  /// [item] - данные вещи
  /// 
  /// Endpoint: POST /api/v1/wardrobe
  Future<WardrobeItem> createWardrobeItem(WardrobeItem item) async {
    try {
      final body = _prepareItemBody(item);
      
      final response = await _apiClient.post('/api/v1/wardrobe', data: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final itemData = data['item'] as Map<String, dynamic>? ?? data;
        return WardrobeItem.fromJson(itemData);
      } else {
        throw WardrobeException('Ошибка создания вещи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка создания вещи: $e');
    }
  }

  /// Обновить вещь в гардеробе
  /// 
  /// [item] - обновленные данные вещи
  /// 
  /// Endpoint: PUT /api/v1/wardrobe/{id}
  Future<WardrobeItem> updateWardrobeItem(WardrobeItem item) async {
    try {
      if (item.id == null) {
        throw WardrobeException('ID вещи не указан');
      }
      
      final body = _prepareItemBody(item);
      
      final response = await _apiClient.put('/api/v1/wardrobe/${item.id}', data: body);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final itemData = data['item'] as Map<String, dynamic>? ?? data;
        return WardrobeItem.fromJson(itemData);
      } else {
        throw WardrobeException('Ошибка обновления вещи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка обновления вещи: $e');
    }
  }

  /// Удалить вещь из гардероба
  /// 
  /// [id] - ID вещи
  /// 
  /// Endpoint: DELETE /api/v1/wardrobe/{id}
  Future<void> deleteWardrobeItem(String id) async {
    try {
      final response = await _apiClient.delete('/api/v1/wardrobe/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw WardrobeException('Ошибка удаления вещи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка удаления вещи: $e');
    }
  }

  /// Добавить вещь в избранное
  /// 
  /// [id] - ID вещи
  /// 
  /// Endpoint: POST /api/v1/wardrobe/{id}/favorite
  Future<WardrobeItem> toggleFavorite(String id) async {
    try {
      final response = await _apiClient.post('/api/v1/wardrobe/$id/favorite');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final itemData = data['item'] as Map<String, dynamic>? ?? data;
        return WardrobeItem.fromJson(itemData);
      } else {
        throw WardrobeException('Ошибка обновления избранного: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка обновления избранного: $e');
    }
  }

  /// Архивировать вещь
  /// 
  /// [id] - ID вещи
  /// 
  /// Endpoint: POST /api/v1/wardrobe/{id}/archive
  Future<WardrobeItem> archiveWardrobeItem(String id) async {
    try {
      final response = await _apiClient.post('/api/v1/wardrobe/$id/archive');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final itemData = data['item'] as Map<String, dynamic>? ?? data;
        return WardrobeItem.fromJson(itemData);
      } else {
        throw WardrobeException('Ошибка архивирования вещи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка архивирования вещи: $e');
    }
  }

  /// Отметить вещь как использованную
  /// 
  /// [id] - ID вещи
  /// 
  /// Endpoint: POST /api/v1/wardrobe/{id}/worn
  Future<WardrobeItem> markAsWorn(String id) async {
    try {
      final response = await _apiClient.post('/api/v1/wardrobe/$id/worn');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final itemData = data['item'] as Map<String, dynamic>? ?? data;
        return WardrobeItem.fromJson(itemData);
      } else {
        throw WardrobeException('Ошибка отметки вещи: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка отметки вещи: $e');
    }
  }

  /// Подготовить тело запроса для вещи
  Map<String, dynamic> _prepareItemBody(WardrobeItem item) {
    final body = <String, dynamic>{};
    
    if (item.name != null) body['name'] = item.name;
    if (item.category != null) body['category'] = item.category;
    if (item.subcategory != null) body['subcategory'] = item.subcategory;
    if (item.brand != null) body['brand'] = item.brand;
    if (item.color != null) body['color'] = item.color;
    if (item.size != null) body['size'] = item.size;
    if (item.imageUrl != null) body['image_url'] = item.imageUrl;
    if (item.style != null) body['style'] = item.style;
    if (item.gender != null) body['gender'] = item.gender;
    if (item.fit != null) body['fit'] = item.fit;
    if (item.pattern != null) body['pattern'] = item.pattern;
    if (item.season != null) body['season'] = item.season;
    if (item.minTemp != null) body['min_temp'] = item.minTemp;
    if (item.maxTemp != null) body['max_temp'] = item.maxTemp;
    if (item.warmthLevel != null) body['warmth_level'] = item.warmthLevel;
    if (item.rainOk != null) body['rain_ok'] = item.rainOk;
    if (item.snowOk != null) body['snow_ok'] = item.snowOk;
    if (item.windOk != null) body['wind_ok'] = item.windOk;
    if (item.isFavorite != null) body['is_favorite'] = item.isFavorite;
    if (item.isArchived != null) body['is_archived'] = item.isArchived;
    if (item.materials != null) body['materials'] = item.materials;
    
    return body;
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw WardrobeException('Превышено время ожидания. Проверьте соединение.');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      throw WardrobeException('Нет соединения с интернетом.');
    }
    
    final statusCode = e.response?.statusCode;
    final errorMessage = _extractErrorMessage(e.response?.data);
    
    switch (statusCode) {
      case 401:
        throw WardrobeException('Требуется авторизация');
      case 403:
        throw WardrobeException('Нет доступа');
      case 404:
        throw WardrobeException('Вещь не найдена');
      case 422:
        throw WardrobeException(errorMessage ?? 'Неверные данные');
      case 500:
        throw WardrobeException('Ошибка сервера');
      default:
        throw WardrobeException('Ошибка сети: ${e.message}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? 
             data['error'] as String?;
    }
    return null;
  }
}

/// Результат получения списка вещей
class WardrobeListResult {
  final List<WardrobeItem> items;
  final int total;

  WardrobeListResult({
    required this.items,
    required this.total,
  });
}

/// Исключение репозитория гардероба
class WardrobeException implements Exception {
  final String message;
  
  const WardrobeException(this.message);
  
  @override
  String toString() => 'WardrobeException: $message';
}
