/// Интерфейс репозитория профиля
abstract class IProfileRepository {
  /// Получить профиль текущего пользователя
  Future<Map<String, dynamic>> getProfile();

  /// Обновить профиль
  Future<void> updateProfile(Map<String, dynamic> profile);

  /// Обновить настройки
  Future<void> updatePreferences(Map<String, dynamic> preferences);
}
