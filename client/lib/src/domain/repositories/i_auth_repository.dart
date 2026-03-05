import 'package:outfitstyle_client/src/core/models/token_pair.dart';

/// Интерфейс репозитория аутентификации (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
abstract class IAuthRepository {
  Future<TokenPair?> login(String email, String password);
  Future<TokenPair?> register(String email, String password, String name);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getUserId();
}
