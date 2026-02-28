import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import '../../services/auth_storage.dart';
import '../../models/token_pair.dart';

class ApiClient {
  final AuthStorage storage;

  late final Dio _dio;

  ApiClient({required this.storage}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Interceptor для авторизации и refresh токена
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final tokenPair = await storage.readTokenPair();
        final token = tokenPair?.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          // Отладка: нет токена
          print('[ApiClient] Нет токена для запроса: ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onError: (DioException err, ErrorInterceptorHandler handler) async {
        // Логируем ошибки для отладки
        print('[ApiClient] Error: ${err.type} ${err.requestOptions.path} - ${err.response?.statusCode}');

        // Если 401 и это не запрос к auth endpoint - пробуем refresh
        if (err.response?.statusCode == 401) {
          final path = err.requestOptions.path;
          
          // Не пытаемся refresh для auth endpoints чтобы избежать бесконечного цикла
          if (!path.contains('/auth/')) {
            try {
              print('[ApiClient] Попытка refresh токена...');
              final refreshed = await _refreshToken();
              
              if (refreshed) {
                print('[ApiClient] Токен обновлён, повторяем запрос...');
                // Повторяем оригинальный запрос с новым токеном
                final RequestOptions originalRequest = err.requestOptions;
                final tokenPair = await storage.readTokenPair();
                final newToken = tokenPair?.accessToken;

                if (newToken != null) {
                  final response = await _dio.fetch(
                    RequestOptions(
                      method: originalRequest.method,
                      path: originalRequest.path,
                      data: originalRequest.data,
                      queryParameters: originalRequest.queryParameters,
                      headers: {
                        ...originalRequest.headers,
                        'Authorization': 'Bearer $newToken',
                      },
                    ),
                  );
                  return handler.resolve(response);
                }
              }
            } catch (refreshError) {
              print('[ApiClient] Ошибка refresh: $refreshError');
              // Если refresh не удался - очищаем сессию
              await storage.clearSession();
            }
          }
        }
        
        return handler.next(err);
      },
    ));
  }

  /// Refresh токена
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('[ApiClient] Нет refresh токена');
        return false;
      }

      // Используем /api/auth/refresh (не /api/v1/auth/refresh)
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>?;

        if (tokens != null) {
          final newTokenPair = TokenPair.fromJson(tokens);
          await storage.saveTokenPair(newTokenPair);
          print('[ApiClient] Токен успешно обновлён');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('[ApiClient] Ошибка refresh токена: $e');
      return false;
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

  Object mapError(Object e) {
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
  Future<void> saveToken(TokenPair token) async {}

  @override
  Future<TokenPair?> getToken() async => null;

  @override
  Future<void> clear() async {}

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> saveTokenPair(TokenPair pair) async {}

  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<TokenPair?> readTokenPair() async => null;

  @override
  Future<DateTime?> readExpiresAt() async => null;
}
