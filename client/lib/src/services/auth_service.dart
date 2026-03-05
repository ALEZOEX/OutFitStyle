import 'package:outfitstyle_client/src/core/models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';
import 'package:dio/dio.dart';

/// Сервис аутентификации для Market Service API
///
/// Используется ТОЛЬКО для взаимодействия с Market Service (покупка одежды).
/// НЕ используется для пользовательской аутентификации (вход/выход).
///
/// Пользовательская аутентификация: SessionManager (Firebase Auth)
/// Market Service API: AuthService (JWT токены)
///
/// @see SessionManager для пользовательской аутентификации
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
    throw UnimplementedError('Используйте SessionManager.signIn() вместо AuthService.login()');
  }

  /// Регистрация нового пользователя
  Future<TokenPair?> register(String email, String password, String name) async {
    throw UnimplementedError('Используйте SessionManager.signUp() вместо AuthService.register()');
  }

  Future<void> logout() async {
    await authStorage.clearSession();
  }

  /// Тихий вход (восстановление сессии)
  Future<TokenPair?> silentLogin() async {
    return await authStorage.readTokenPair();
  }

  /// Валидация текущего токена
  Future<bool> validateToken() async {
    final token = await authStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}

/// Исключение аутентификации
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
