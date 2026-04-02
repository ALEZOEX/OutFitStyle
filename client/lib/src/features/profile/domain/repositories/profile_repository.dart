/// Репозиторий профиля
abstract class ProfileRepository {
  const ProfileRepository();

  /// Получить данные профиля
  Future<Map<String, dynamic>?> getProfile(String userId);

  /// Обновить данные профиля
  Future<bool> updateProfile(String userId, Map<String, dynamic> data);
}
