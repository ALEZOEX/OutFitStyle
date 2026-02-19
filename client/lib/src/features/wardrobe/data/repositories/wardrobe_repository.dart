import '../../../../core/api/api_client.dart';
import '../../../../data/remote/wardrobe_api_service.dart';
import '../../../../domain/entities/wardrobe_item.dart';
import '../../../../domain/entities/wardrobe_request_entities.dart';

/// Репозиторий для работы с гардеробом пользователя
///
/// Взаимодействует с API эндпоинтами:
/// - GET /api/wardrobe — список вещей
/// - POST /api/wardrobe — создание вещи
/// - GET /api/wardrobe/{id} — получение вещи
/// - PUT /api/wardrobe/{id} — обновление вещи
/// - DELETE /api/wardrobe/{id} — удаление вещи
class WardrobeRepository {
  final WardrobeApiService _apiService;

  WardrobeRepository({
    required WardrobeApiService apiService,
  }) : _apiService = apiService;

  /// Получить список вещей гардероба
  ///
  /// [category] — фильтр по категории
  /// [style] — фильтр по стилю
  /// [isFavorite] — фильтр по избранному
  /// [includeArchived] — включать архивированные
  /// [page] — номер страницы
  /// [limit] — количество на странице
  /// [search] — поисковый запрос
  Future<WardrobeListResult> getWardrobeItems({
    String? category,
    String? style,
    bool? isFavorite,
    bool includeArchived = false,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final response = await _apiService.getWardrobeItems(
        includeArchived: includeArchived,
        category: category,
        style: style,
        isFavorite: isFavorite,
        page: page,
        limit: limit,
        search: search,
      );

      return WardrobeListResult(
        items: response.items,
        total: response.total,
      );
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка получения гардероба: $e');
    }
  }

  /// Получить вещь по ID
  Future<WardrobeItem> getWardrobeItem(String id) async {
    try {
      final item = await _apiService.getWardrobeItem(id);
      return item;
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка получения вещи: $e');
    }
  }

  /// Создать новую вещь в гардеробе
  Future<WardrobeItem> createWardrobeItem(WardrobeItemCreateRequest request) async {
    try {
      final item = await _apiService.createWardrobeItem(request);
      return item;
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка создания вещи: $e');
    }
  }

  /// Обновить вещь в гардеробе
  Future<WardrobeItem> updateWardrobeItem(String id, WardrobeItemUpdateRequest request) async {
    try {
      final item = await _apiService.updateWardrobeItem(id, request);
      return item;
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка обновления вещи: $e');
    }
  }

  /// Удалить вещь из гардероба
  Future<void> deleteWardrobeItem(String id) async {
    try {
      await _apiService.deleteWardrobeItem(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка удаления вещи: $e');
    }
  }

  /// Добавить/удалить вещь из избранного
  Future<WardrobeItem> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _apiService.toggleFavorite(id, isFavorite);
      return await getWardrobeItem(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка обновления избранного: $e');
    }
  }

  /// Архивировать/восстановить вещь
  Future<WardrobeItem> archiveWardrobeItem(String id, bool isArchived) async {
    try {
      await _apiService.toggleArchive(id, isArchived);
      return await getWardrobeItem(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка архивирования вещи: $e');
    }
  }

  /// Отметить вещь как использованную
  Future<void> markAsWorn(String id) async {
    try {
      await _apiService.markAsWorn(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } catch (e) {
      if (e is WardrobeException) rethrow;
      throw WardrobeException('Ошибка отметки вещи: $e');
    }
  }

  /// Преобразовать API исключение в исключение репозитория
  WardrobeException _mapApiException(WardrobeApiException e) {
    switch (e.statusCode) {
      case 401:
        return const WardrobeException('Требуется авторизация');
      case 403:
        return const WardrobeException('Нет доступа');
      case 404:
        return const WardrobeException('Вещь не найдена');
      case 422:
        return WardrobeException(e.details?['message']?.toString() ?? e.message);
      case 500:
        return const WardrobeException('Ошибка сервера');
      default:
        return WardrobeException(e.message);
    }
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
