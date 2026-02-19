import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_pair.dart';

class AuthStorage {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kExpiresAt = 'expires_at';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(TokenPair token) async {
    await writeTokenPair(token);
  }

  Future<void> saveTokenPair(TokenPair pair) async {
    await writeTokenPair(pair);
  }

  Future<TokenPair?> getToken() async {
    return readTokenPair();
  }

  Future<void> clear() async {
    await clearSession();
  }

  Future<void> writeTokenPair(TokenPair pair) async {
    await _storage.write(key: _kAccessToken, value: pair.accessToken);
    await _storage.write(key: _kRefreshToken, value: pair.refreshToken);
    await _storage.write(
        key: _kExpiresAt, value: pair.expiresAt.toIso8601String());
  }

  Future<String?> readAccessToken() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.accessToken;
  }

  Future<String?> readRefreshToken() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.refreshToken;
  }

  Future<TokenPair?> readTokenPair() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);
    final expiresAtStr = await _storage.read(key: _kExpiresAt);

    if (access == null || refresh == null) return null;

    final expiresAt =
        expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;

    // Проверяем, истек ли токен, но НЕ очищаем сессию сразу
    // Это позволит использовать токен до его фактической проверки на сервере
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      // Токен истёк, но не очищаем сессию - пусть сервер решит, нужна ли очистка
      // await clearSession();
      // return null;
    }

    return TokenPair(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kExpiresAt);
  }

  Future<DateTime?> readExpiresAt() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.expiresAt;
  }
}
