import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';

/// PublicApiClient — HTTP клиент для публичных endpoints (без авторизации)
///
/// Используется для:
/// - Регистрации (/auth/register)
/// - Логина (/auth/login)
/// - Восстановления пароля (/auth/forgot-password, /auth/reset-password)
///
/// НЕ добавляет Firebase ID Token в заголовки
class PublicApiClient {
  late final Dio _dio;

  PublicApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      extra: {'withCredentials': true}, // Для httpOnly cookie на вебе
    ));
  }

  Dio get raw => _dio;

  /// POST-запрос (для регистрации, логина, сброса пароля)
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(_normalizePath(path), data: data);
      return response;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// GET-запрос
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(_normalizePath(path), queryParameters: params);
      return response;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }

  Exception _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Нет соединения с сервером');
    }
    if (e.response?.statusCode == 400) {
      final data = e.response?.data;
      if (data is Map) {
        return Exception(data['message'] ?? 'Ошибка запроса');
      }
      return Exception('Ошибка запроса');
    }
    if (e.response?.statusCode == 401) {
      return Exception('Неверный email или пароль');
    }
    if (e.response?.statusCode == 409) {
      return Exception('Пользователь с таким email уже существует');
    }
    if (e.response?.statusCode == 429) {
      return Exception('Слишком много попыток. Попробуйте позже');
    }
    return Exception('Ошибка сервера: ${e.response?.statusCode}');
  }
}
