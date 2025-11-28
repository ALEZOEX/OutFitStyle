import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyAccessToken = 'access_token';
  static const _keyUserId = 'user_id';

  Future<String?> readAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _keyUserId);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  Future<void> saveSession({
    required int userId,
    required String accessToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}