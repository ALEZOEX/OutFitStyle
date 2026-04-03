import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../domain/entities/saved_outfit.dart';

/// Сервис для работы с API сохранённых образов
///
/// Эндпоинты:
/// - GET /api/v1/outfits — получить все образы
/// - POST /api/v1/outfits — создать образ
/// - GET /api/v1/outfits/{id} — получить образ по ID
/// - PUT /api/v1/outfits/{id} — обновить образ
/// - DELETE /api/v1/outfits/{id} — удалить образ
/// - POST /api/v1/outfits/{id}/worn — отметить что образ был надет
class OutfitApiService {
  final ApiClient _apiClient;

  OutfitApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Получить список сохранённых образов
  ///
  /// [page] — номер страницы (по умолчанию 1)
  /// [limit] — количество на странице (по умолчанию 50)
  Future<SavedOutfitListResponse> getOutfits({
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    final response = await _apiClient.get('/api/v1/outfits', params: params);

    if (response.statusCode == 200) {
      final rawData = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;

      return SavedOutfitListResponse.fromJson(rawData);
    } else {
      throw OutfitApiException(
        'Ошибка получения образов: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Получить образ по ID
  Future<SavedOutfit> getOutfitById(String id) async {
    final response = await _apiClient.get('/api/v1/outfits/$id');

    if (response.statusCode == 200) {
      final rawData = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;

      return SavedOutfit.fromJson(rawData);
    } else {
      throw OutfitApiException(
        'Ошибка получения образа: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Создать новый образ
  Future<SavedOutfit> createOutfit(SavedOutfitCreateRequest request) async {
    final response = await _apiClient.post(
      '/api/v1/outfits',
      data: request.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final rawData = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;

      return SavedOutfit.fromJson(rawData);
    } else {
      throw OutfitApiException(
        'Ошибка создания образа: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Обновить образ
  Future<SavedOutfit> updateOutfit(
    String id,
    SavedOutfitUpdateRequest request,
  ) async {
    final response = await _apiClient.put(
      '/api/v1/outfits/$id',
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      final rawData = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;

      return SavedOutfit.fromJson(rawData);
    } else {
      throw OutfitApiException(
        'Ошибка обновления образа: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Удалить образ
  Future<void> deleteOutfit(String id) async {
    final response = await _apiClient.delete('/api/v1/outfits/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw OutfitApiException(
        'Ошибка удаления образа: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Отметить что образ был надет (increment timesWorn)
  Future<Map<String, dynamic>> markAsWorn(String id) async {
    final response = await _apiClient.post('/api/v1/outfits/$id/worn');

    if (response.statusCode == 200) {
      final rawData = response.data is Map
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;

      return rawData;
    } else {
      throw OutfitApiException(
        'Ошибка отметки образа: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

/// Исключение API образов
class OutfitApiException implements Exception {
  final String message;
  final int? statusCode;

  const OutfitApiException(this.message, {this.statusCode});

  @override
  String toString() => 'OutfitApiException: $message (status: $statusCode)';
}
