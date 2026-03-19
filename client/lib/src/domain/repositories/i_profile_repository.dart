import '../entities/user.dart';

abstract class IProfileRepository {
  Future<User?> getUserProfile(String userId);
  Future<void> updateUserProfile(User user);
  Future<void> uploadAvatar(String userId, String imagePath);
  Future<void> deleteAvatar(String userId);
  Future<void> updatePreferences(
    String userId,
    Map<String, dynamic> preferences,
  );
  Future<Map<String, dynamic>?> getPreferences(String userId);
  Future<void> updatePrivacySettings(
    String userId,
    Map<String, dynamic> settings,
  );
  Future<Map<String, dynamic>?> getPrivacySettings(String userId);
  Future<void> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  );
  Future<Map<String, dynamic>?> getNotificationSettings(String userId);
  Future<List<String>> getUserInterests(String userId);
  Future<void> updateUserInterests(String userId, List<String> interests);
  Future<void> addInterest(String userId, String interest);
  Future<void> removeInterest(String userId, String interest);
  Future<int> getUserPoints(String userId);
  Future<void> addUserPoints(String userId, int points);
  Future<String> getUserLevel(String userId);
  Future<Map<String, dynamic>> getUserStats(String userId);
  Future<void> addSocialLink(String userId, String platform, String link);
  Future<void> removeSocialLink(String userId, String platform);
  Future<Map<String, String>> getSocialLinks(String userId);
}
