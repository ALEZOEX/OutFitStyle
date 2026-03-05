import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';
import 'package:outfitstyle_client/src/core/models/token_pair.dart';

/// Репозиторий аутентификации для Market Service API
///
/// Используется ТОЛЬКО для взаимодействия с Market Service (покупка одежды).
/// НЕ используется для пользовательской аутентификации (вход/выход).
///
/// Пользовательская аутентификация: SessionManager (Firebase Auth)
/// Market Service API: AuthRepository (JWT токены)
///
/// @see SessionManager для пользовательской аутентификации
abstract class IAuthRepository {
  Future<TokenPair?> login(String email, String password);
  Future<TokenPair?> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getUserId();
}

/// Репозиторий аутентификации (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
class AuthRepository implements IAuthRepository {
  final ApiConfig config;
  final AuthStorage authStorage;
  final ApiClient apiClient;

  AuthRepository(this.config, this.authStorage, this.apiClient);

  @override
  Future<TokenPair?> login(String email, String password) async {
    throw UnimplementedError('Используйте SessionManager.signIn() вместо AuthRepository.login()');
  }

  @override
  Future<TokenPair?> register(String email, String password, String name) async {
    throw UnimplementedError('Используйте SessionManager.signUp() вместо AuthRepository.register()');
  }

  @override
  Future<void> logout() async {
    await authStorage.clearSession();
  }

  @override
  Future<bool> isAuthenticated() async {
    final tokens = await authStorage.readTokenPair();
    return tokens != null && !tokens.isExpired;
  }

  @override
  Future<String?> getUserId() async {
    // Для JWT токенов нужно декодировать payload
    // Для обратной совместимости возвращаем null
    return null;
  }

  /// Refresh токена
  Future<TokenPair?> refreshToken() async {
    throw UnimplementedError('Используйте SessionManager вместо AuthRepository.refreshToken()');
  }

  /// Валидация токена
  Future<bool> validateToken() async {
    final token = await authStorage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
