import 'package:dio/dio.dart';

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

  WardrobeRepository({required WardrobeApiService apiService})
    : _apiService = apiService;

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

      return WardrobeListResult(items: response.items, total: response.total);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } on FormatException catch (e) {
      throw WardrobeException('Ошибка формата данных: ${e.message}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка получения гардероба: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Получить вещь по ID
  Future<WardrobeItem> getWardrobeItem(String id) async {
    try {
      final item = await _apiService.getWardrobeItem(id);
      return item;
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка получения вещи: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Создать новую вещь в гардеробе
  Future<WardrobeItem> createWardrobeItem(
    WardrobeItemCreateRequest request,
  ) async {
    try {
      final item = await _apiService.createWardrobeItem(request);
      return item;
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка создания вещи: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Обновить вещь в гардеробе
  Future<WardrobeItem> updateWardrobeItem(
    String id,
    WardrobeItemUpdateRequest request,
  ) async {
    try {
      final item = await _apiService.updateWardrobeItem(id, request);
      return item;
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка обновления вещи: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Удалить вещь из гардероба
  Future<void> deleteWardrobeItem(String id) async {
    try {
      await _apiService.deleteWardrobeItem(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка удаления вещи: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Добавить/удалить вещь из избранного
  Future<WardrobeItem> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _apiService.toggleFavorite(id, isFavorite);
      return await getWardrobeItem(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка обновления избранного: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Архивировать/восстановить вещь
  Future<WardrobeItem> archiveWardrobeItem(String id, bool isArchived) async {
    try {
      await _apiService.toggleArchive(id, isArchived);
      return await getWardrobeItem(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка архивирования вещи: ${_extractErrorMessage(e)}',
      );
    }
  }

  /// Отметить вещь как использованную
  Future<void> markAsWorn(String id) async {
    try {
      await _apiService.markAsWorn(id);
    } on WardrobeApiException catch (e) {
      throw _mapApiException(e);
    } on WardrobeException {
      rethrow;
    } on DioException catch (e) {
      throw WardrobeException('Ошибка сети: ${e.message ?? e.type.name}');
    } catch (e) {
      throw WardrobeException(
        'Ошибка отметки вещи: ${_extractErrorMessage(e)}',
      );
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
        return WardrobeException(
          e.details?['message']?.toString() ?? e.message,
        );
      case 500:
        return const WardrobeException('Ошибка сервера');
      default:
        return WardrobeException(e.message);
    }
  }

  /// Безопасно извлечь сообщение об ошибке из любого объекта исключения.
  ///
  /// В релизной сборке Dart обфусцирует имена классов, поэтому
  /// обычная интерполяция '$e' даёт 'Instance of minified:acz'.
  /// Этот метод проверяет тип и вызывает доступные свойства.
  static String _extractErrorMessage(Object error) {
    if (error is WardrobeException) return error.message;
    if (error is WardrobeApiException) return error.message;
    if (error is DioException) return error.message ?? error.type.name;
    if (error is FormatException) return error.message;
    if (error is TypeError) return 'Ошибка типа данных';
    try {
      final s = error.toString();
      if (s.startsWith('Instance of')) {
        return error.runtimeType.toString();
      }
      return s;
    } catch (_) {
      return 'Неизвестная ошибка';
    }
  }
}

/// Результат получения списка вещей
class WardrobeListResult {
  final List<WardrobeItem> items;
  final int total;

  WardrobeListResult({required this.items, required this.total});
}

/// Исключение репозитория гардероба
class WardrobeException implements Exception {
  final String message;

  const WardrobeException(this.message);

  @override
  String toString() => 'WardrobeException: $message';
}
