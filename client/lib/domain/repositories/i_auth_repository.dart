abstract class IAuthRepository {
  Future<bool> isAuthed();
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<String?> getAuthToken();
  Future<void> refreshToken();
  Future<void> updateProfile(Map<String, dynamic> profileData);
  Future<Map<String, dynamic>> getProfile();
}