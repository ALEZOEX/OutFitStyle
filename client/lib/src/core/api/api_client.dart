import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';
import 'package:outfitstyle_client/src/core/models/token_pair.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async' show Completer;
import 'dart:developer' as developer;
import 'web_utils.dart' if (dart.library.io) 'web_utils_stub.dart' as web_utils;

/// ApiClient — HTTP клиент с авторизацией и automatic token refresh
/// 
/// Platform-specific поведение:
/// - Web: refresh token в httpOnly cookie, access token в памяти
/// - Mobile: оба токена в FlutterSecureStorage
class ApiClient {
  final AuthStorage storage;

  late final Dio _dio;
  
  // Security: флаг для предотвращения race condition при refresh
  bool _isRefreshing = false;
  
  // Очередь запросов, ожидающих refresh
  final List<_PendingRequest> _pendingRequests = [];

  ApiClient({required this.storage}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      extra: {'withCredentials': true}, // Security: для отправки httpOnly cookie на вебе
    ));

    // Security: для web включаем отправку cookies через interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Security: для web браузер автоматически отправляет cookies (httpOnly cookie для refresh token)
        // при same-origin запросах. Для cross-origin нужно настроить CORS на сервере.
        // withCredentials уже установлен в BaseOptions
        
        final tokenPair = await storage.readTokenPair();
        final token = tokenPair?.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          // Отладка: нет токена
          developer.log('[ApiClient] Нет токена',
              name: 'ApiClient',
              level: 900,
              error: 'No token for ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        // Логируем ошибки для отладки
        developer.log('[ApiClient] Error',
            name: 'ApiClient',
            level: 1000,
            error: '${err.type} ${err.requestOptions.path} - ${err.response?.statusCode}');

        // Если 401 и это не запрос к auth endpoint - пробуем refresh
        if (err.response?.statusCode == 401) {
          final path = err.requestOptions.path;

          // Не пытаемся refresh для auth endpoints чтобы избежать бесконечного цикла
          // Исключение: /auth/refresh — это endpoint refresh
          final isAuthEndpoint = path.contains('/auth/') && !path.contains('/auth/refresh');
          
          if (!isAuthEndpoint) {
            try {
              developer.log('[ApiClient] Попытка refresh токена', name: 'ApiClient');
              final refreshed = await _refreshToken();

              if (refreshed) {
                developer.log('[ApiClient] Токен обновлён, повторяем запрос', name: 'ApiClient');
                
                // Повторяем оригинальный запрос с новым токеном
                final opts = err.requestOptions;
                final tokenPair = await storage.readTokenPair();
                final newToken = tokenPair?.accessToken;

                if (newToken != null) {
                  opts.headers['Authorization'] = 'Bearer $newToken';
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                }
              }
            } catch (refreshError) {
              developer.log('[ApiClient] Ошибка refresh',
                  name: 'ApiClient',
                  error: refreshError);
              // Если refresh не удался — очищаем сессию и перезагружаем страницу
              await storage.clearSession();
              // Перезагрузка страницы для web или редирект на login
              if (kIsWeb) {
                // Для web — перезагрузка страницы
                web_utils.reloadPage();
              }
            }
          }
        }

        return handler.next(err);
      },
    ));
  }

  /// Refresh токена
  /// Security: предотвращает race condition при параллельных 401 ответах
  /// Web: refresh token в httpOnly cookie, отправляется браузером автоматически
  /// Mobile: refresh token в body запроса
  Future<bool> _refreshToken() async {
    // Security: предотвращаем race condition — только один refresh одновременно
    if (_isRefreshing) {
      developer.log('[ApiClient] Refresh уже выполняется, ждём', name: 'ApiClient');
      // Ждём завершения текущего refresh (до 10 секунд)
      final startTime = DateTime.now();
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (DateTime.now().difference(startTime) > const Duration(seconds: 10)) {
          developer.log('[ApiClient] Timeout waiting for refresh', name: 'ApiClient');
          return false;
        }
      }
      // Refresh уже выполнен другим запросом, проверяем есть ли токен
      final tokenPair = await storage.readTokenPair();
      return tokenPair?.accessToken != null;
    }

    _isRefreshing = true;
    try {
      // Web: refresh token в httpOnly cookie — не нужен в body
      // Mobile: читаем refresh token из secure storage
      String? refreshToken;
      if (!kIsWeb) {
        refreshToken = await storage.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          developer.log('[ApiClient] Нет refresh токена', name: 'ApiClient');
          return false;
        }
      }

      // Используем отдельный Dio без interceptors для refresh
      // чтобы избежать рекурсии и конфликтов с interceptor
      final plainDio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': true}, // Security: для отправки httpOnly cookie на вебе
      ));

      // Формируем запрос
      // Web: refresh token в cookie, body может быть пустым
      // Mobile: refresh token в body
      dynamic data;
      if (!kIsWeb && refreshToken != null) {
        data = {'refresh_token': refreshToken};
      } else {
        // Web: cookie отправляется браузером автоматически
        data = {};
      }

      // Используем /api/v1/auth/refresh
      // Web: браузер автоматически отправляет refresh token cookie
      // Mobile: отправляем refresh token в body
      final response = await plainDio.post(
        '/api/v1/auth/refresh',
        data: data,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>?;

        if (tokens != null) {
          final newTokenPair = TokenPair.fromJson(tokens);
          await storage.writeTokenPair(newTokenPair);
          developer.log('[ApiClient] Токен успешно обновлён', name: 'ApiClient');
          return true;
        }
      }

      developer.log('[ApiClient] Refresh failed: status ${response.statusCode}', name: 'ApiClient');
      return false;
    } catch (e) {
      developer.log('[ApiClient] Ошибка refresh токена',
          name: 'ApiClient',
          error: e);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Внутренний конструктор для использования с кастомным Dio
  /// (например, для внешних API без авторизации)
  ApiClient.internal(Dio dio) : _dio = dio, storage = _NoOpAuthStorage();

  Dio get raw => _dio;

  /// Нормализует path — убирает leading slash для корректной работы с baseUrl
  String _normalizePath(String path) {
    // Убираем leading slash чтобы Dio обрабатывал path как относительный
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

/// Заглушка AuthStorage для случаев, когда авторизация не требуется
class _NoOpAuthStorage extends AuthStorage {
  _NoOpAuthStorage();

  @override
  Future<void> writeTokenPair(TokenPair pair) async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<TokenPair?> readTokenPair() async => null;

  @override
  Future<DateTime?> readExpiresAt() async => null;

  @override
  Future<void> clearSession() async {}
}

/// Внутренний класс для ожидания завершения refresh
class _PendingRequest {
  final Completer<void> completer = Completer<void>();
  final String path;
  
  _PendingRequest(this.path);
  
  Future<void> wait() => completer.future;
  void resolve() => completer.complete();
  void reject(Object error) => completer.completeError(error);
}
