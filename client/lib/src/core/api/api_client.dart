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

    // Interceptor для авторизации
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final tokenPair = await storage.getToken();
        final token = tokenPair?.accessToken;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException err, handler) {
        // Можем добавить логику для обработки ошибок
        return handler.next(err);
      },
    ));
  }

  /// Внутренний конструктор для использования с кастомным Dio
  /// (например, для внешних API без авторизации)
  ApiClient.internal(Dio dio) : _dio = dio, storage = _NoOpAuthStorage();

  Dio get raw => _dio;

  // GET-запрос
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  // POST-запрос
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  // PUT-запрос
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw mapError(e);
    }
  }

  // DELETE-запрос
  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
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
