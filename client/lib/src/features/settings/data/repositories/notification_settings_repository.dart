import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../domain/entities/notification_settings.dart';

/// Репозиторий для работы с настройками уведомлений пользователя
///
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/users/notifications/settings - получение настроек
/// - PUT /api/v1/users/notifications/settings - обновление настроек
///
/// Также поддерживает локальное кэширование в SharedPreferences
class NotificationSettingsRepository {
  final ApiClient _apiClient;

  NotificationSettingsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Получить настройки уведомлений с сервера
  ///
  /// Endpoint: GET /api/v1/users/notifications/settings
  Future<NotificationSettings> getSettings() async {
    try {
      final response = await _apiClient.get('/api/v1/users/notifications/settings');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final settingsData = data['notification_settings'] as Map<String, dynamic>? ?? data;
        return NotificationSettings.fromMap(settingsData);
      } else if (response.statusCode == 404) {
        // Настройки ещё не созданы, возвращаем дефолтные
        return NotificationSettings.defaultSettings();
      } else {
        throw NotificationSettingsException(
          'Ошибка получения настроек: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NotificationSettingsException) rethrow;
      throw NotificationSettingsException('Ошибка получения настроек: $e');
    }
  }

  /// Обновить настройки уведомлений на сервере
  ///
  /// [settings] - новые настройки уведомлений
  ///
  /// Endpoint: PUT /api/v1/users/notifications/settings
  Future<NotificationSettings> updateSettings(NotificationSettings settings) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/users/notifications/settings',
        data: settings.toMap(),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final settingsData = data['notification_settings'] as Map<String, dynamic>? ?? data;
        return NotificationSettings.fromMap(settingsData);
      } else {
        throw NotificationSettingsException(
          'Ошибка обновления настроек: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is NotificationSettingsException) rethrow;
      throw NotificationSettingsException('Ошибка обновления настроек: $e');
    }
  }

  /// Синхронизировать локальные настройки с сервером
  ///
  /// [localSettings] - локальные настройки
  /// Возвращает актуальные настройки (с сервера или локальные при ошибке)
  Future<NotificationSettings> syncWithServer(NotificationSettings localSettings) async {
    try {
      return await updateSettings(localSettings);
    } catch (e) {
      // При ошибке синхронизации возвращаем локальные настройки
      return localSettings;
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NotificationSettingsException(
        'Превышено время ожидания. Проверьте соединение.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      throw NotificationSettingsException('Нет соединения с интернетом.');
    }

    final statusCode = e.response?.statusCode;
    final errorMessage = _extractErrorMessage(e.response?.data);

    switch (statusCode) {
      case 401:
        throw NotificationSettingsException('Требуется авторизация');
      case 403:
        throw NotificationSettingsException('Нет доступа');
      case 422:
        throw NotificationSettingsException(errorMessage ?? 'Неверные данные');
      case 500:
        throw NotificationSettingsException('Ошибка сервера');
      default:
        throw NotificationSettingsException('Ошибка сети: ${e.message}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}

/// Исключение репозитория настроек уведомлений
class NotificationSettingsException implements Exception {
  final String message;

  const NotificationSettingsException(this.message);

  @override
  String toString() => 'NotificationSettingsException: $message';
}
