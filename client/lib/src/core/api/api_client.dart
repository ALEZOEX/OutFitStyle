import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';
import 'package:outfitstyle_client/src/core/models/token_pair.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async' show Completer;
import 'dart:developer' as developer;
import 'web_utils.dart' if (dart.library.io) 'web_utils_stub.dart' as web_utils;

/// ApiClient — HTTP клиент с Firebase ID Token авторизацией
///
/// Отправляет Firebase ID Token в заголовке Authorization: Bearer <token>
/// Бэкенд должен проверять Firebase ID Token через Firebase Admin SDK
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

    // Interceptor для добавления Firebase ID Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Получаем Firebase ID Token
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          try {
            // getIdToken() автоматически refresh токен если нужно
            final idToken = await user.getIdToken();
            if (idToken != null && idToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $idToken';
              developer.log('[ApiClient] Firebase ID Token добавлен',
                  name: 'ApiClient',
                  level: 900);
            } else {
              developer.log('[ApiClient] Firebase ID Token пуст',
                  name: 'ApiClient',
                  level: 900,
                  error: 'Empty ID token for ${options.method} ${options.path}');
            }
          } catch (e) {
            developer.log('[ApiClient] Ошибка получения Firebase ID Token',
                name: 'ApiClient',
                level: 1000,
                error: e);
          }
        } else {
          developer.log('[ApiClient] Пользователь не авторизован',
              name: 'ApiClient',
              level: 900,
              error: 'No user for ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        // Логируем ошибки для отладки
        developer.log('[ApiClient] Error',
            name: 'ApiClient',
            level: 1000,
            error: '${err.type} ${err.requestOptions.path} - ${err.response?.statusCode}');

        // Если 401 — пробуем refresh Firebase ID Token
        if (err.response?.statusCode == 401) {
          final path = err.requestOptions.path;

          // Не пытаемся refresh для auth endpoints
          final isAuthEndpoint = path.contains('/auth/');

          if (!isAuthEndpoint) {
            try {
              developer.log('[ApiClient] Попытка refresh Firebase ID Token', name: 'ApiClient');
              final refreshed = await _refreshFirebaseToken();

              if (refreshed) {
                developer.log('[ApiClient] Firebase ID Token обновлён, повторяем запрос', name: 'ApiClient');

                // Повторяем оригинальный запрос с новым токеном
                final opts = err.requestOptions;
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final newToken = await user.getIdToken(true); // Force refresh
                  if (newToken != null) {
                    opts.headers['Authorization'] = 'Bearer $newToken';
                    final response = await _dio.fetch(opts);
                    return handler.resolve(response);
                  }
                }
              }
            } catch (refreshError) {
              developer.log('[ApiClient] Ошибка refresh Firebase ID Token',
                  name: 'ApiClient',
                  error: refreshError);
              // Если refresh не удался — очищаем сессию и перезагружаем страницу
              await storage.clearSession();
              // Перезагрузка страницы для web или редирект на login
              if (kIsWeb) {
                web_utils.reloadPage();
              }
            }
          }
        }

        return handler.next(err);
      },
    ));
  }

  /// Refresh Firebase ID Token
  /// Firebase SDK автоматически управляет refresh токеном
  Future<bool> _refreshFirebaseToken() async {
    if (_isRefreshing) {
      developer.log('[ApiClient] Refresh уже выполняется, ждём', name: 'ApiClient');
      final startTime = DateTime.now();
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (DateTime.now().difference(startTime) > const Duration(seconds: 10)) {
          developer.log('[ApiClient] Timeout waiting for refresh', name: 'ApiClient');
          return false;
        }
      }
      return true;
    }

    _isRefreshing = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        developer.log('[ApiClient] Нет пользователя для refresh', name: 'ApiClient');
        return false;
      }

      // Force refresh Firebase ID Token
      final newToken = await user.getIdToken(true);
      if (newToken != null && newToken.isNotEmpty) {
        developer.log('[ApiClient] Firebase ID Token успешно обновлён', name: 'ApiClient');
        return true;
      }

      developer.log('[ApiClient] Firebase ID Token пуст после refresh', name: 'ApiClient');
      return false;
    } catch (e) {
      developer.log('[ApiClient] Ошибка refresh Firebase ID Token',
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
