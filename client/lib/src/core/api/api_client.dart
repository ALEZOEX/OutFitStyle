import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'dart:developer' as developer;

/// ApiClient — HTTP клиент для авторизованных запросов
///
/// Авторизация работает через httpOnly cookie (refresh token)
/// Backend сам управляет сессией через cookie
///
/// Для web: cookie отправляется автоматически (withCredentials: true)
/// Для mobile: требуется дополнительная настройка cookie jar
class ApiClient {
  late final Dio _dio;
  final SharedPreferences? _sharedPreferences;

  ApiClient(SharedPreferences sharedPreferences)
      : _sharedPreferences = sharedPreferences {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      extra: {'withCredentials': true}, // Важно: отправка cookie на вебе
    ));

    // Interceptor для добавления Authorization header
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Skip Authorization header for login/register endpoints
        final path = options.path;
        if (!path.contains('/auth/login') &&
            !path.contains('/auth/register') &&
            !path.contains('/auth/forgot-password') &&
            !path.contains('/auth/reset-password') &&
            !path.contains('/auth/google')) {
          // Get access_token from SharedPreferences
          final accessToken = _sharedPreferences?.getString('access_token');
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
            developer.log('[ApiClient] Added Authorization header', name: 'ApiClient');
          }
        }
        return handler.next(options);
      },
    ));

    // Interceptor для логирования
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('[ApiClient] Request: ${options.method} ${options.path}',
            name: 'ApiClient',
            level: 900);
        return handler.next(options);
      },
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        developer.log('[ApiClient] Error',
            name: 'ApiClient',
            level: 1000,
            error: '${err.type} ${err.requestOptions.path} - ${err.response?.statusCode}');

        // Если 401 — логируем для отладки
        if (err.response?.statusCode == 401) {
          developer.log('[ApiClient] 401 ошибка — требуется авторизация', name: 'ApiClient');
        }

        return handler.next(err);
      },
    ));
  }

  Dio get raw => _dio;

  /// Внутренний конструктор для использования с кастомным Dio
  /// (например, для Weather API без авторизации)
  ApiClient.internal(Dio dio)
      : _dio = dio,
        _sharedPreferences = null;

  String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }

  // GET-запрос
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(_normalizePath(path), queryParameters: params);
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  // POST-запрос
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(_normalizePath(path), data: data);
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  // PUT-запрос
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(_normalizePath(path), data: data);
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  // DELETE-запрос
  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(_normalizePath(path));
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  ApiException mapError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return const NetworkException('Нет соединения');
      }
      if (e.response?.statusCode == 401) {
        return const UnauthorizedException('Требуется авторизация');
      }
      return ApiException('Ошибка сервера: ${e.response?.statusCode}');
    }
    return const ApiException('Неизвестная ошибка');
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}
