import '../../../../core/api/api_client.dart';
import 'package:dio/dio.dart';

/// Репозиторий для работы с предпочтениями пользователя
///
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/users/preferences - получение предпочтений
/// - PUT /api/v1/users/preferences - обновление предпочтений
class PreferencesRepository {
  final ApiClient _apiClient;

  PreferencesRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Получить предпочтения пользователя
  ///
  /// Endpoint: GET /api/v1/users/preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/users/preferences');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prefData = data['preferences'] as Map<String, dynamic>? ?? data;
        return prefData;
      } else {
        throw PreferencesException('Ошибка получения предпочтений: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is PreferencesException) rethrow;
      throw PreferencesException('Ошибка получения предпочтений: $e');
    }
  }

  /// Обновить предпочтения пользователя
  ///
  /// [preferences] - новые предпочтения
  ///
  /// Endpoint: PUT /api/v1/users/preferences
  Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final body = _preparePreferencesBody(preferences);

      final response = await _apiClient.put(
        '/api/v1/users/preferences',
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prefData = data['preferences'] as Map<String, dynamic>? ?? data;
        return prefData;
      } else {
        throw PreferencesException('Ошибка обновления предпочтений: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is PreferencesException) rethrow;
      throw PreferencesException('Ошибка обновления предпочтений: $e');
    }
  }

  /// Подготовить тело запроса для обновления предпочтений
  Map<String, dynamic> _preparePreferencesBody(Map<String, dynamic> preferences) {
    final body = <String, dynamic>{};

    // Поля из preferences
    if (preferences.containsKey('preferred_temperature') &&
        (preferences['preferred_temperature'] as String).isNotEmpty) {
      body['preferred_temperature'] = preferences['preferred_temperature'];
    }

    if (preferences.containsKey('preferred_colors') &&
        (preferences['preferred_colors'] as List).isNotEmpty) {
      body['preferred_colors'] = preferences['preferred_colors'];
    }

    if (preferences.containsKey('preferred_styles') &&
        (preferences['preferred_styles'] as List).isNotEmpty) {
      body['preferred_styles'] = preferences['preferred_styles'];
    }

    if (preferences.containsKey('preferred_brands') &&
        (preferences['preferred_brands'] as List).isNotEmpty) {
      body['preferred_brands'] = preferences['preferred_brands'];
    }

    if (preferences.containsKey('excluded_items') &&
        (preferences['excluded_items'] as List).isNotEmpty) {
      body['excluded_items'] = preferences['excluded_items'];
    }

    if (preferences.containsKey('prefers_natural_materials')) {
      body['prefers_natural_materials'] = preferences['prefers_natural_materials'];
    }
    if (preferences.containsKey('prefers_synthetic_materials')) {
      body['prefers_synthetic_materials'] = preferences['prefers_synthetic_materials'];
    }
    if (preferences.containsKey('sensitive_to_cold')) {
      body['sensitive_to_cold'] = preferences['sensitive_to_cold'];
    }
    if (preferences.containsKey('sensitive_to_heat')) {
      body['sensitive_to_heat'] = preferences['sensitive_to_heat'];
    }

    if (preferences.containsKey('occasions_of_interest') &&
        (preferences['occasions_of_interest'] as List).isNotEmpty) {
      body['occasions_of_interest'] = preferences['occasions_of_interest'];
    }

    if (preferences.containsKey('max_budget') && preferences['max_budget'] != null) {
      body['max_budget'] = preferences['max_budget'];
    }

    if (preferences.containsKey('fit_preference') && preferences['fit_preference'] != null) {
      body['fit_preference'] = preferences['fit_preference'];
    }

    return body;
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw PreferencesException('Превышено время ожидания. Проверьте соединение.');
    }
    
    if (e.type == DioExceptionType.connectionError) {
      throw PreferencesException('Нет соединения с интернетом.');
    }
    
    final statusCode = e.response?.statusCode;
    final errorMessage = _extractErrorMessage(e.response?.data);
    
    switch (statusCode) {
      case 401:
        throw PreferencesException('Требуется авторизация');
      case 403:
        throw PreferencesException('Нет доступа');
      case 422:
        throw PreferencesException(errorMessage ?? 'Неверные данные');
      case 500:
        throw PreferencesException('Ошибка сервера');
      default:
        throw PreferencesException('Ошибка сети: ${e.message}');
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

/// Исключение репозитория предпочтений
class PreferencesException implements Exception {
  final String message;
  
  const PreferencesException(this.message);
  
  @override
  String toString() => 'PreferencesException: $message';
}
