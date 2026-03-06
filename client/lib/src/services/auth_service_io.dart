import 'package:dio/dio.dart';

/// Сервис аутентификации для Mobile (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
class AuthService {
  final String apiBase;
  final Dio dio;

  AuthService({
    required this.apiBase,
    required this.dio,
  });

  /// Вход через Google для Mobile
  Future<void> loginWithGoogle() async {
    throw UnimplementedError('Используйте SessionManager.signInWithGoogle() вместо AuthService.loginWithGoogle()');
  }

  /// Тихий вход
  Future<void> silentLogin() async {
    // JWT auth больше не используется
  }
}

/// Исключение аутентификации
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
