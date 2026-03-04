/// Интерфейс репозитория аутентификации
abstract class IAuthRepository {
  /// Войти с помощью email и пароля
  Future<bool> login(String email, String password);

  /// Зарегистрироваться
  Future<bool> register(String email, String password, String name);

  /// Выйти из системы
  Future<void> logout();

  /// Проверить, авторизован ли пользователь
  Future<bool> isLoggedIn();

  /// Проверить, авторизован ли пользователь (алиас для isLoggedIn)
  Future<bool> isAuthed() => isLoggedIn();

  /// Обновить access токен через refresh endpoint
  Future<bool> refreshToken();

  /// Получить ID пользователя
  Future<String?> getUserId();

  /// Получить данные текущего пользователя
  Future<Map<String, dynamic>?> getCurrentUser();

  /// Запросить восстановление пароля (отправка кода на email)
  Future<bool> forgotPassword(String email);

  /// Сбросить пароль по коду
  Future<bool> resetPassword(String email, String code, String newPassword);
}
