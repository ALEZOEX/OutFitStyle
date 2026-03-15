import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'dart:developer' as developer;
import '../../utils/logger.dart';

/// ApiClient — HTTP клиент для авторизованных запросов
///
/// Авторизация работает через Firebase ID Token
/// Токен получается динамически перед каждым запросом через getIdToken()
///
/// Для web: cookie отправляется автоматически (withCredentials: true)
/// Для mobile: cookie jar не требуется (используется Bearer token)
class ApiClient {
  late final Dio _dio;
  final SharedPreferences? _sharedPreferences;
  final FirebaseAuth _firebaseAuth;

  ApiClient({SharedPreferences? sharedPreferences, FirebaseAuth? firebaseAuth})
      : _sharedPreferences = sharedPreferences,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      extra: {'withCredentials': true}, // Важно: отправка cookie на вебе
    ));

    // Interceptor для добавления Authorization header с Firebase ID Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final timestamp = DateTime.now().toIso8601String();
        final path = options.path;

        // Skip Authorization header for public endpoints
        if (!path.contains('/auth/login') &&
            !path.contains('/auth/register') &&
            !path.contains('/auth/forgot-password') &&
            !path.contains('/auth/reset-password') &&
            !path.contains('/auth/google') &&
            !path.contains('/auth/verify-reset-code')) {

          String? firebaseIdToken;

          try {
            // Получаем текущего пользователя Firebase
            final user = _firebaseAuth.currentUser;

            if (user != null) {
              // ВАЖНО: Получаем свежий Firebase ID Token с force refresh=true
              // Это гарантирует что токен актуален и не истёк
              firebaseIdToken = await user.getIdToken(true);

              if (firebaseIdToken != null) {
                developer.log('[$timestamp] [ApiClient] [Request] ${options.method} ${options.path}', name: 'ApiClient');
                developer.log('[$timestamp] [ApiClient] [Auth] Firebase ID Token получен (длина: ${firebaseIdToken.length} символов)', name: 'ApiClient');

                if (firebaseIdToken.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $firebaseIdToken';
                  developer.log('[$timestamp] [ApiClient] [Auth] Authorization header добавлен с Firebase ID Token', name: 'ApiClient');
                } else {
                  developer.log('[$timestamp] [ApiClient] [Auth] WARNING: Firebase ID Token пустой', name: 'ApiClient');
                  AppLogger.warning('[$timestamp] [ApiClient] Запрос с пустым Firebase ID Token: ${options.method} ${options.path}');
                }
              } else {
                developer.log('[$timestamp] [ApiClient] [Auth] WARNING: Firebase ID Token = null', name: 'ApiClient');
                AppLogger.warning('[$timestamp] [ApiClient] Запрос с null Firebase ID Token: ${options.method} ${options.path}');
              }
            } else {
              developer.log('[$timestamp] [ApiClient] [Auth] WARNING: Firebase currentUser = null', name: 'ApiClient');
              AppLogger.warning('[$timestamp] [ApiClient] Запрос без авторизации (Firebase user = null): ${options.method} ${options.path}');
            }
          } catch (e) {
            developer.log('[$timestamp] [ApiClient] [Auth] ERROR получения Firebase ID Token: $e', name: 'ApiClient');
            AppLogger.error('[$timestamp] [ApiClient] Ошибка получения Firebase ID Token: $e');

            // Пробуем fallback на access_token из SharedPreferences
            final accessToken = _sharedPreferences?.getString('access_token');
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
              developer.log('[$timestamp] [ApiClient] [Auth] Fallback: используем access_token из SharedPreferences', name: 'ApiClient');
            }
          }
        } else {
          developer.log('[$timestamp] [ApiClient] [Request] ${options.method} ${options.path} (public endpoint, no auth)', name: 'ApiClient');
        }

        return handler.next(options);
      },
    ));

    // Interceptor для логирования ответов
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final timestamp = DateTime.now().toIso8601String();
        developer.log('[$timestamp] [ApiClient] [HTTP] Отправка запроса: ${options.method} ${options.path}', name: 'ApiClient');
        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        final timestamp = DateTime.now().toIso8601String();
        developer.log('[$timestamp] [ApiClient] [HTTP] Ответ: ${response.statusCode} ${response.requestOptions.path}', name: 'ApiClient');

        if (response.statusCode == 200 || response.statusCode == 201) {
          developer.log('[$timestamp] [ApiClient] [HTTP] Успешный ответ', name: 'ApiClient');
        }

        return handler.next(response);
      },
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        final timestamp = DateTime.now().toIso8601String();
        final statusCode = err.response?.statusCode;

        developer.log('[$timestamp] [ApiClient] [HTTP] Ошибка',
            name: 'ApiClient',
            level: 1000,
            error: '${err.type} ${err.requestOptions.path} - $statusCode');

        // Если 401 — логируем для отладки
        if (statusCode == 401) {
          developer.log('[$timestamp] [ApiClient] [Auth] 401 Unauthorized — требуется авторизация', name: 'ApiClient');
          AppLogger.error('[$timestamp] [ApiClient] 401 ошибка на ${err.requestOptions.path}');

          // Проверяем, есть ли токен
          final accessToken = _sharedPreferences?.getString('access_token');
          if (accessToken == null || accessToken.isEmpty) {
            developer.log('[$timestamp] [ApiClient] [Auth] 401 ошибка: access_token отсутствует в SharedPreferences', name: 'ApiClient');
            AppLogger.error('[$timestamp] [ApiClient] 401 ошибка: access_token не найден');
          } else {
            developer.log('[$timestamp] [ApiClient] [Auth] 401 ошибка: access_token присутствует (${accessToken.length} chars), возможно истёк', name: 'ApiClient');
            AppLogger.error('[$timestamp] [ApiClient] 401 ошибка: access_token есть, но не валиден (возможно истёк)');
          }
        } else if (statusCode != null) {
          AppLogger.error('[$timestamp] [ApiClient] HTTP ошибка $statusCode на ${err.requestOptions.path}');
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
        _sharedPreferences = null,
        _firebaseAuth = FirebaseAuth.instance;

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
