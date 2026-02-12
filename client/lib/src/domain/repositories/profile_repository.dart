import 'package:outfitstyle_client/src/domain/entities/user_preference.dart';

abstract class ProfileRepository {
  /// Получить предпочтения пользователя
  Future<UserPreference> getUserPreferences(String userId);

  /// Обновить предпочтения пользователя
  Future<void> updateUserPreferences(UserPreference userPreference);

  /// Обновить профиль пользователя
  Future<void> updateProfile(String userId, Map<String, dynamic> profileData);
}
