import 'package:dio/dio.dart';
import '../../models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';

/// Сервис аутентификации (обертка над AuthStorage для совместимости)
class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final Dio dio;

  AuthService({
    required this.apiBase,
    required this.authStorage,
    required this.dio,
  });

  /// Вход пользователя по email и паролю
  Future<TokenPair?> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$apiBase/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // Сервер возвращает {"tokens": {...}} или прямой объект
        final tokensData = data['tokens'] as Map<String, dynamic>? ?? data;
        final tokenPair = TokenPair.fromJson(tokensData);
        await authStorage.writeTokenPair(tokenPair);
        return tokenPair;
      } else {
        final error = response.data as Map<String, dynamic>?;
        throw AuthException(error?['message'] ?? 'Ошибка входа');
      }
    } on DioException catch (e) {
      throw AuthException('Ошибка сети: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Ошибка входа: $e');
    }
  }

  /// Регистрация нового пользователя
  Future<TokenPair?> register(String email, String password, String name) async {
    try {
      final response = await dio.post(
        '$apiBase/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tokensData = data['tokens'] as Map<String, dynamic>? ?? data;
        final tokenPair = TokenPair.fromJson(tokensData);
        await authStorage.writeTokenPair(tokenPair);
        return tokenPair;
      } else {
        final error = response.data as Map<String, dynamic>?;
        throw AuthException(error?['message'] ?? 'Ошибка регистрации');
      }
    } on DioException catch (e) {
      throw AuthException('Ошибка сети: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Ошибка регистрации: $e');
    }
  }

  Future<void> logout() async {
    await authStorage.clearSession();
  }

  /// Тихий вход (восстановление сессии по сохранённому токену)
  Future<TokenPair?> silentLogin() async {
    try {
      final existingPair = await authStorage.readTokenPair();
      if (existingPair == null) {
        return null;
      }

      // Если токен ещё действителен, возвращаем его
      if (!existingPair.isExpired) {
        return existingPair;
      }

      // Токен истёк, пробуем обновить через refresh
      final response = await dio.post(
        '$apiBase/api/v1/auth/refresh',
        data: {
          'refresh_token': existingPair.refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // Сервер возвращает {"tokens": {...}}
        final tokensData = data['tokens'] as Map<String, dynamic>? ?? data;
        final tokenPair = TokenPair.fromJson(tokensData);
        await authStorage.writeTokenPair(tokenPair);
        return tokenPair;
      } else {
        await authStorage.clearSession();
        return null;
      }
    } on DioException catch (e) {
      throw AuthException('Ошибка сети: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Ошибка тихого входа: $e');
    }
  }

  /// Валидация текущего токена
  Future<bool> validateToken() async {
    try {
      final token = await authStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await dio.get(
        '$apiBase/auth/validate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.statusCode == 200;
    } on DioException {
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Исключение аутентификации
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}