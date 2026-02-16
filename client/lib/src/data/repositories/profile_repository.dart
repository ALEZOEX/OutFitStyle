import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../services/auth_storage.dart';

/// Репозиторий профиля пользователя
class ProfileRepository {
  final ApiConfig config;
  final AuthStorage authStorage;
  final ApiClient apiClient;

  ProfileRepository(this.config, this.authStorage, this.apiClient);

  /// Получить профиль текущего пользователя
  Future<Map<String, dynamic>> getMe() async {
    final response = await apiClient.get('/users/me');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw ProfileException('Не удалось загрузить профиль');
  }

  /// Обновить настройки пользователя
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    final response = await apiClient.put(
      '/users/me/preferences',
      data: preferences,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ProfileException('Не удалось обновить настройки');
    }
  }

  /// Обновить профиль пользователя
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final response = await apiClient.put(
      '/users/me',
      data: profileData,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ProfileException('Не удалось обновить профиль');
    }
  }

  void dispose() {
    // ApiClient не требует явного закрытия
  }
}

/// Исключение репозитория профиля
class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}