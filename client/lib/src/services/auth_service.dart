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
  final Dio dio;

  AuthService({
    required this.apiBase,
    required this.dio,
  });

  /// Вход пользователя по email и паролю
  Future<void> login(String email, String password) async {
    throw UnimplementedError('Используйте SessionManager.signIn() вместо AuthService.login()');
  }

  /// Регистрация нового пользователя
  Future<void> register(String email, String password, String name) async {
    throw UnimplementedError('Используйте SessionManager.signUp() вместо AuthService.register()');
  }

  Future<void> logout() async {
    // JWT auth больше не используется
  }

  /// Тихий вход (восстановление сессии)
  Future<void> silentLogin() async {
    // JWT auth больше не используется
  }

  /// Валидация текущего токена
  Future<bool> validateToken() async {
    // JWT auth больше не используется
    return false;
  }
}

/// Исключение аутентификации
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
