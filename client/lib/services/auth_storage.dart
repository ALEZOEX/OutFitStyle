import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyUserId = 'user_id';

  /// Прочитать сохранённый access token (JWT/opaque) или null.
  Future<String?> readAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Прочитать сохранённый userId (int) или null.
  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _keyUserId);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  /// Сохранить текущую сессию пользователя.
  Future<void> saveSession({
    required int userId,
    required String accessToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  /// Очистить все сохранённые данные аутентификации.
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}