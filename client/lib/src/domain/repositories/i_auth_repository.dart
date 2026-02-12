abstract class IAuthRepository {
  Future<bool> isAuthed();
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUser();
}