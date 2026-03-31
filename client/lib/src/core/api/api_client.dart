import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import '../../utils/logger.dart';
import 'web_token_storage_selector.dart';

/// Получение access_token из localStorage (только для Web)
/// SharedPreferences на Web может быть не инициализирован вовремя
String? _getAccessTokenFromLocalStorage() {
  final token = getAccessTokenFromLocalStorage();
  if (token != null && token.isNotEmpty) {
    final timestamp = DateTime.now().toIso8601String();
    developer.log(
      '[$timestamp] [ApiClient] ✅ Token read from localStorage (${token.length} chars)',
      name: 'ApiClient',
    );
  }
  return token;
}

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
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': true}, // Важно: отправка cookie на вебе
      ),
    );

    // Interceptor для добавления Authorization header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final timestamp = DateTime.now().toIso8601String();
          final path = options.path;

          developer.log(
            '[$timestamp] [ApiClient] [Interceptor 1] START processing: ${options.method} ${options.path}',
            name: 'ApiClient',
          );

          // Skip Authorization header for public endpoints
          if (!path.contains('/auth/login') &&
              !path.contains('/auth/register') &&
              !path.contains('/auth/forgot-password') &&
              !path.contains('/auth/reset-password') &&
              !path.contains('/auth/google') &&
              !path.contains('/auth/verify-reset-code')) {
            String? accessToken;

            // 🔑 DEBUG LOGS
            developer.log(
              '🔑 [AUTH DEBUG] ============== REQUEST START ==============',
              name: 'AuthDebug',
            );
            developer.log(
              '🔑 [AUTH DEBUG] Path: ${options.method} ${options.path}',
              name: 'AuthDebug',
            );

            // 🔑 КРИТИЧНО: На Web читаем ТОЛЬКО из localStorage (SharedPreferences не работает)
            if (kIsWeb) {
              accessToken = _getAccessTokenFromLocalStorage();
              if (accessToken != null && accessToken.isNotEmpty) {
                developer.log(
                  '🔑 [AUTH DEBUG] ✅ Token read from localStorage (Web)',
                  name: 'AuthDebug',
                );
              }
            } else {
              // Mobile/Desktop: читаем из SharedPreferences
              accessToken = _sharedPreferences?.getString('access_token');
            }

            if (accessToken != null && accessToken.isNotEmpty) {
              // Определяем тип токена по структуре JWT (xxx.xxx.xxx)
              final tokenParts = accessToken.split('.');
              final isJwt = tokenParts.length == 3;

              // 🔑 DEBUG: Детальная информация о токене
              developer.log(
                '🔑 [AUTH DEBUG] ✅ Backend Access Token найден',
                name: 'AuthDebug',
              );
              developer.log(
                '🔑 [AUTH DEBUG] Длина: ${accessToken.length} символов',
                name: 'AuthDebug',
              );
              developer.log(
                '🔑 [AUTH DEBUG] JWT формат: $isJwt',
                name: 'AuthDebug',
              );
              developer.log(
                '🔑 [AUTH DEBUG] Preview: ${accessToken.substring(0, accessToken.length > 50 ? 50 : accessToken.length)}...',
                name: 'AuthDebug',
              );

              // Backend Access Token всегда приоритетнее Firebase ID Token
              developer.log(
                '🔑 [AUTH DEBUG] ✅ ИСПОЛЬЗУЕМ Backend JWT Access Token (приоритет)',
                name: 'AuthDebug',
              );
            } else {
              // Приоритет 2: Firebase ID Token (fallback для совместимости)
              developer.log(
                '🔑 [AUTH DEBUG] ⚠️ Backend Access Token НЕ найден в SharedPreferences',
                name: 'AuthDebug',
              );
              developer.log(
                '🔑 [AUTH DEBUG] Пытаемся получить Firebase ID Token...',
                name: 'AuthDebug',
              );

              try {
                final user = _firebaseAuth.currentUser;
                developer.log(
                  '🔑 [AUTH DEBUG] Firebase currentUser: ${user != null ? "UID=${user.uid}" : "NULL"}',
                  name: 'AuthDebug',
                );

                if (user != null) {
                  accessToken = await user.getIdToken(true);
                  developer.log(
                    '🔑 [AUTH DEBUG] Firebase ID Token получен: ${accessToken != null ? "${accessToken.length} символов" : "NULL"}',
                    name: 'AuthDebug',
                  );

                  if (accessToken != null && accessToken.isNotEmpty) {
                    // Проверяем, что это Firebase ID Token (не JWT backend)
                    final tokenParts = accessToken.split('.');
                    final isFirebaseToken = tokenParts.length == 3;

                    developer.log(
                      '🔑 [AUTH DEBUG] ⚠️ ИСПОЛЬЗУЕМ Firebase ID Token (fallback)',
                      name: 'AuthDebug',
                    );
                    developer.log(
                      '🔑 [AUTH DEBUG] Firebase Token preview: ${accessToken.substring(0, accessToken.length > 50 ? 50 : accessToken.length)}...',
                      name: 'AuthDebug',
                    );
                    developer.log(
                      '🔑 [AUTH DEBUG] Token structure: parts=${tokenParts.length}, isFirebase=$isFirebaseToken',
                      name: 'AuthDebug',
                    );

                    // 🔴 WARNING: Если это Firebase ID Token, backend может вернуть 401
                    if (accessToken.length > 1000) {
                      developer.log(
                        '🔑 [AUTH DEBUG] 🔴 WARNING: Токен >1000 символов - это Firebase ID Token, а не backend JWT!',
                        name: 'AuthDebug',
                      );
                      developer.log(
                        '🔑 [AUTH DEBUG] 🔴 Рекомендуется проверить, что /api/v1/auth/google вернул JWT токен',
                        name: 'AuthDebug',
                      );
                    }
                  }
                }
              } catch (e) {
                developer.log(
                  '🔑 [AUTH DEBUG] ❌ ERROR получения Firebase ID Token: $e',
                  name: 'AuthDebug',
                );
                AppLogger.error(
                  '[$timestamp] [ApiClient] Ошибка получения Firebase ID Token: $e',
                );
              }
            }

            // Устанавливаем Authorization header
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
              developer.log(
                '🔑 [AUTH DEBUG] ✅ Authorization header SET (Bearer ${accessToken.length} chars)',
                name: 'AuthDebug',
              );
            } else {
              developer.log(
                '🔑 [AUTH DEBUG] ❌ WARNING: Токен не найден',
                name: 'AuthDebug',
              );
              AppLogger.warning(
                '[$timestamp] [ApiClient] Запрос без токена: ${options.method} ${options.path}',
              );
            }

            developer.log(
              '🔑 [AUTH DEBUG] Final headers: ${options.headers}',
              name: 'AuthDebug',
            );
            developer.log(
              '🔑 [AUTH DEBUG] ============== REQUEST END ==============',
              name: 'AuthDebug',
            );
          } else {
            developer.log(
              '[$timestamp] [ApiClient] [Interceptor 1] Public endpoint detected: ${options.path}, skipping Authorization header',
              name: 'ApiClient',
            );
          }

          developer.log(
            '[$timestamp] [ApiClient] [Interceptor 1] END processing, calling handler.next()',
            name: 'ApiClient',
          );
          return handler.next(options);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          final timestamp = DateTime.now().toIso8601String();
          final statusCode = err.response?.statusCode;

          developer.log(
            '[$timestamp] [ApiClient] [Interceptor 1 onError] DioException caught: ${err.type} ${err.requestOptions.path} - $statusCode',
            name: 'ApiClient',
            level: 1000,
            error: err,
          );
          developer.log(
            '[$timestamp] [ApiClient] [Interceptor 1 onError] Error message: ${err.message}',
            name: 'ApiClient',
          );
          developer.log(
            '[$timestamp] [ApiClient] [Interceptor 1 onError] Response data: ${err.response?.data ?? 'null'}',
            name: 'ApiClient',
          );

          return handler.next(err);
        },
      ),
    );

    // Interceptor 2: Сохранение токенов из response (auth endpoints)
    // Критично: должен выполняться ДО interceptor'а авторизации
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          final timestamp = DateTime.now().toIso8601String();
          final path = response.requestOptions.path;

          // Извлекаем токены только из auth endpoints
          if (path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/google') ||
              path.contains('/auth/refresh')) {
            final data = response.data;
            if (data is Map) {
              final tokens = data['tokens'] as Map?;
              if (tokens != null) {
                final accessToken = tokens['access_token'] as String?;
                final refreshToken = tokens['refresh_token'] as String?;

                if (accessToken != null && accessToken.isNotEmpty) {
                  _sharedPreferences?.setString('access_token', accessToken);
                  developer.log(
                    '[$timestamp] [ApiClient] [Interceptor 2] ✅ ACCESS TOKEN сохранён из response (${accessToken.length} chars)',
                    name: 'ApiClient',
                  );

                  // 🔑 DEBUG: Верификация типа токена
                  final tokenParts = accessToken.split('.');
                  final isJwt = tokenParts.length == 3;
                  developer.log(
                    '[$timestamp] [ApiClient] [Interceptor 2] 🔑 Token type: JWT=$isJwt, parts=${tokenParts.length}',
                    name: 'ApiClient',
                  );
                }

                if (refreshToken != null && refreshToken.isNotEmpty) {
                  _sharedPreferences?.setString('refresh_token', refreshToken);
                  developer.log(
                    '[$timestamp] [ApiClient] [Interceptor 2] ✅ REFRESH TOKEN сохранён из response (${refreshToken.length} chars)',
                    name: 'ApiClient',
                  );
                }
              }
            }
          }

          developer.log(
            '[$timestamp] [ApiClient] [Interceptor 2] HTTP Response: ${response.statusCode} ${response.requestOptions.path}',
            name: 'ApiClient',
          );

          return handler.next(response);
        },
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          final timestamp = DateTime.now().toIso8601String();
          final statusCode = err.response?.statusCode;

          if (statusCode != 401) {
            // 401 обрабатывается в AuthInterceptor
            AppLogger.error(
              '[$timestamp] [ApiClient] HTTP ошибка $statusCode на ${err.requestOptions.path}',
            );
          }

          return handler.next(err);
        },
      ),
    );

    // Interceptor 3: Auth — перехват 401 с диагностикой
    _dio.interceptors.add(
      AuthInterceptor(sharedPreferences: _sharedPreferences),
    );
  }

  Dio get raw => _dio;

  /// Внутренний конструктор для использования с кастомным Dio
  /// (например, для Weather API без авторизации)
  ApiClient.internal(Dio dio, {FirebaseAuth? firebaseAuth})
    : _dio = dio,
      _sharedPreferences = null,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }

  // GET-запрос
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(
        _normalizePath(path),
        queryParameters: params,
      );
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

      // Извлекаем конкретное сообщение об ошибке из тела ответа бэкенда
      final responseData = e.response?.data;
      if (responseData is Map) {
        // Формат validation errors: {"error": "validation failed", "errors": {"field": "msg"}}
        if (responseData.containsKey('errors') &&
            responseData['errors'] is Map) {
          final errors = responseData['errors'] as Map;
          if (errors.isNotEmpty) {
            final messages = errors.values.map((v) => v.toString()).join('; ');
            return ApiException(messages);
          }
        }
        // Формат простой ошибки: {"error": "message"}
        if (responseData.containsKey('error') &&
            responseData['error'] is String) {
          final msg = responseData['error'] as String;
          if (msg.isNotEmpty && msg != 'validation failed') {
            return ApiException(msg);
          }
        }
      }

      return ApiException(
        'Ошибка сервера: ${e.response?.statusCode ?? 'unknown'}',
      );
    }
    return const ApiException('Неизвестная ошибка');
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

/// Interceptor для обработки 401 Unauthorized
///
/// - Логирует диагностику (есть ли токен, валидность)
/// - Очищает невалидный токен из SharedPreferences
/// - Пробрасывает ошибку с понятным сообщением
class AuthInterceptor extends Interceptor {
  final SharedPreferences? sharedPreferences;

  AuthInterceptor({this.sharedPreferences});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final timestamp = DateTime.now().toIso8601String();
      final path = '${err.requestOptions.method} ${err.requestOptions.path}';

      developer.log(
        '[$timestamp] [AuthInterceptor] ╔═══════════════════════════════════════════',
        name: 'AuthInterceptor',
        level: 1000,
      );
      developer.log(
        '[$timestamp] [AuthInterceptor] ║ 401 Unauthorized',
        name: 'AuthInterceptor',
        level: 1000,
      );
      developer.log(
        '[$timestamp] [AuthInterceptor] ║ Path: $path',
        name: 'AuthInterceptor',
        level: 1000,
      );

      // Проверяем наличие токена
      final token = sharedPreferences?.getString('access_token');
      if (token == null || token.isEmpty) {
        developer.log(
          '[$timestamp] [AuthInterceptor] ║ Токен ОТСУТСТВУЕТ — запрос ушёл без авторизации',
          name: 'AuthInterceptor',
          level: 1000,
        );
        AppLogger.error('[AuthInterceptor] 401: запрос без токена на $path');
      } else {
        developer.log(
          '[$timestamp] [AuthInterceptor] ║ Токен ПРИСУТСТВУЕТ (${token.length} chars), но не валиден',
          name: 'AuthInterceptor',
          level: 1000,
        );
        AppLogger.error(
          '[AuthInterceptor] 401: токен истёк или невалиден на $path',
        );
      }

      developer.log(
        '[$timestamp] [AuthInterceptor] ╚═══════════════════════════════════════════',
        name: 'AuthInterceptor',
        level: 1000,
      );
    }

    // Пробрасываем ошибку дальше (ApiClient.mapError() преобразует в UnauthorizedException)
    handler.next(err);
  }
}
