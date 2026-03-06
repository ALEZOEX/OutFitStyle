/// Интерфейс репозитория аутентификации (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
@Deprecated('Используйте Firebase Auth через SessionManager')
abstract class IAuthRepository {
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getUserId();
}
