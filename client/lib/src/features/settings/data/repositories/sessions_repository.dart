import '../../../../core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../models/session_device.dart';

/// Репозиторий для управления сессиями пользователя
///
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/user/sessions - получение списка сессий
/// - DELETE /api/v1/user/sessions/{session_id} - удаление сессии
class SessionsRepository {
  final ApiClient _apiClient;

  SessionsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Получить список всех сессий пользователя
  ///
  /// Endpoint: GET /api/v1/user/sessions
  Future<List<SessionDevice>> getSessions() async {
    try {
      final response = await _apiClient.get('/api/v1/user/sessions');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final sessionsData =
            data['sessions'] as List<dynamic>? ??
            (data['data'] as List<dynamic>? ?? []);

        return sessionsData
            .map((json) => SessionDevice.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw SessionsException(
          'Ошибка получения сессий: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is SessionsException) rethrow;
      throw SessionsException('Ошибка получения сессий: $e');
    }
  }

  /// Удалить сессию по ID
  ///
  /// [sessionId] - ID сессии для удаления
  ///
  /// Endpoint: DELETE /api/v1/user/sessions/{session_id}
  Future<void> deleteSession(String sessionId) async {
    try {
      final response = await _apiClient.delete(
        '/api/v1/user/sessions/$sessionId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw SessionsException(
          'Ошибка удаления сессии: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is SessionsException) rethrow;
      throw SessionsException('Ошибка удаления сессии: $e');
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw SessionsException(
        'Превышено время ожидания. Проверьте соединение.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      throw SessionsException('Нет соединения с интернетом.');
    }

    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 401:
        throw SessionsException('Требуется авторизация');
      case 403:
        throw SessionsException('Нет доступа');
      case 404:
        throw SessionsException('Сессия не найдена');
      case 500:
        throw SessionsException('Ошибка сервера');
      default:
        throw SessionsException('Ошибка сети: ${e.message}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}

/// Исключение репозитория сессий
class SessionsException implements Exception {
  final String message;

  const SessionsException(this.message);

  @override
  String toString() => 'SessionsException: $message';
}
