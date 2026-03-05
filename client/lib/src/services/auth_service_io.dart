import 'package:outfitstyle_client/src/core/models/token_pair.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';
import 'package:dio/dio.dart';

/// Сервис аутентификации для Mobile (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final Dio dio;

  AuthService({
    required this.apiBase,
    required this.authStorage,
    required this.dio,
  });

  /// Вход через Google для Mobile
  Future<TokenPair> loginWithGoogle() async {
    throw UnimplementedError('Используйте SessionManager.signInWithGoogle() вместо AuthService.loginWithGoogle()');
  }

  /// Тихий вход
  Future<TokenPair> silentLogin() async {
    final token = await authStorage.readAccessToken();
    final refresh = await authStorage.readRefreshToken();
    final expires = await authStorage.readExpiresAt();
    
    if (token == null || refresh == null) {
      throw AuthException('Нет сохранённых токенов');
    }
    
    return TokenPair(
      accessToken: token,
      refreshToken: refresh,
      expiresAt: expires,
    );
  }
}

/// Исключение аутентификации
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
