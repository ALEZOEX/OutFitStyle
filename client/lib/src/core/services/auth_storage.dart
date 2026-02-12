import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_pair.dart';

class AuthStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiresAtKey = 'token_expires_at';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveTokens(TokenPair tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
    await _storage.write(
        key: _tokenExpiresAtKey, value: tokens.expiresAt.toIso8601String());
  }

  Future<TokenPair?> getTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final expiresAtStr = await _storage.read(key: _tokenExpiresAtKey);

    if (accessToken == null || refreshToken == null || expiresAtStr == null) {
      return null;
    }

    return TokenPair(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.parse(expiresAtStr),
    );
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiresAtKey);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
}