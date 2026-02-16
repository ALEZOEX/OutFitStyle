import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/token_pair.dart';
import '../../services/auth_storage.dart';

/// Сервис аутентификации (обертка над AuthStorage для совместимости)
class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final http.Client httpClient;

  AuthService({
    required this.apiBase,
    required this.authStorage,
    required this.httpClient,
  });

  /// Вход пользователя по email и паролю
  Future<TokenPair?> login(String email, String password) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokenPair = TokenPair.fromJson(data);
        await authStorage.writeTokenPair(tokenPair);
        return tokenPair;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        throw AuthException(error?['message'] ?? 'Ошибка входа');
      }
    } on http.ClientException catch (e) {
      throw AuthException('Ошибка сети: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Ошибка входа: $e');
    }
  }

  /// Регистрация нового пользователя
  Future<TokenPair?> register(String email, String password, String name) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$apiBase/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokenPair = TokenPair.fromJson(data);
        await authStorage.writeTokenPair(tokenPair);
        return tokenPair;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>?;
        throw AuthException(error?['message'] ?? 'Ошибка регистрации');
      }
    } on http.ClientException catch (e) {
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
      final response = await httpClient.post(
        Uri.parse('$apiBase/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': existingPair.refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokenPair = TokenPair.fromJson(data);
        await authStorage.writeTokenPair(tokenPair);
        return tokenPair;
      } else {
        await authStorage.clearSession();
        return null;
      }
    } on http.ClientException catch (e) {
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

      final response = await httpClient.get(
        Uri.parse('$apiBase/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } on http.ClientException {
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