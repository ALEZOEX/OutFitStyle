import '../../../core/api/api_client.dart';
import '../../entities/user_preference.dart';

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
  Future<UserPreference> getPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/users/preferences');
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prefData = data['preferences'] as Map<String, dynamic>? ?? data;
        return UserPreference.fromJson(prefData);
      } else {
        throw PreferencesException('Ошибка получения предпочтений: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
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
  Future<UserPreference> updatePreferences(UserPreference preferences) async {
    try {
      final body = _preparePreferencesBody(preferences);
      
      final response = await _apiClient.put(
        '/api/v1/users/preferences',
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prefData = data['preferences'] as Map<String, dynamic>? ?? data;
        return UserPreference.fromJson(prefData);
      } else {
        throw PreferencesException('Ошибка обновления предпочтений: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is PreferencesException) rethrow;
      throw PreferencesException('Ошибка обновления предпочтений: $e');
    }
  }

  /// Подготовить тело запроса для обновления предпочтений
  Map<String, dynamic> _preparePreferencesBody(UserPreference preferences) {
    final body = <String, dynamic>{};
    
    // Поля из UserPreference
    if (preferences.preferredTemperature.isNotEmpty) {
      body['preferred_temperature'] = preferences.preferredTemperature;
    }
    
    if (preferences.preferredColors.isNotEmpty) {
      body['preferred_colors'] = preferences.preferredColors;
    }
    
    if (preferences.preferredStyles.isNotEmpty) {
      body['preferred_styles'] = preferences.preferredStyles;
    }
    
    if (preferences.preferredBrands.isNotEmpty) {
      body['preferred_brands'] = preferences.preferredBrands;
    }
    
    if (preferences.excludedItems.isNotEmpty) {
      body['excluded_items'] = preferences.excludedItems;
    }
    
    body['prefers_natural_materials'] = preferences.prefersNaturalMaterials;
    body['prefers_synthetic_materials'] = preferences.prefersSyntheticMaterials;
    body['sensitive_to_cold'] = preferences.sensitiveToCold;
    body['sensitive_to_heat'] = preferences.sensitiveToHeat;
    
    if (preferences.occasionsOfInterest.isNotEmpty) {
      body['occasions_of_interest'] = preferences.occasionsOfInterest;
    }
    
    if (preferences.maxBudget != null) {
      body['max_budget'] = preferences.maxBudget;
    }
    
    if (preferences.fitPreference != null) {
      body['fit_preference'] = preferences.fitPreference;
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
