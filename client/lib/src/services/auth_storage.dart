import 'package:outfitstyle_client/src/core/models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart' as core;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Реализация хранилища токенов (заглушка для обратной совместимости)
/// @Deprecated Используйте Firebase Auth через SessionManager
class AuthStorage implements core.AuthStorage {
  final SharedPreferences _prefs;
  String? _memoryAccessToken; // Для web: access token в памяти

  AuthStorage(this._prefs);

  @override
  Future<void> writeTokenPair(TokenPair pair) async {
    debugPrint('[AuthStorage Legacy] writeTokenPair вызван (для обратной совместимости)');
    if (kIsWeb) {
      // Для web: access token в памяти, refresh в cookie (обрабатывается браузером)
      _memoryAccessToken = pair.accessToken;
    } else {
      // Для mobile: сохраняем в SharedPreferences (небезопасно, только для совместимости)
      await _prefs.setString('legacy_access_token', pair.accessToken);
      await _prefs.setString('legacy_refresh_token', pair.refreshToken);
      if (pair.expiresAt != null) {
        await _prefs.setString('legacy_expires_at', pair.expiresAt!.toIso8601String());
      }
    }
  }

  @override
  Future<String?> readAccessToken() async {
    if (kIsWeb) {
      return _memoryAccessToken;
    } else {
      return _prefs.getString('legacy_access_token');
    }
  }

  @override
  Future<String?> readRefreshToken() async {
    if (kIsWeb) {
      // Для web refresh token в httpOnly cookie — недоступен из JS
      return null;
    } else {
      return _prefs.getString('legacy_refresh_token');
    }
  }

  @override
  Future<TokenPair?> readTokenPair() async {
    final access = await readAccessToken();
    final refresh = await readRefreshToken();
    final expires = await readExpiresAt();

    if (access == null || refresh == null) {
      return null;
    }

    return TokenPair(
      accessToken: access,
      refreshToken: refresh,
      expiresAt: expires,
    );
  }

  @override
  Future<DateTime?> readExpiresAt() async {
    final expiresStr = _prefs.getString('legacy_expires_at');
    if (expiresStr != null) {
      return DateTime.parse(expiresStr);
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    debugPrint('[AuthStorage Legacy] clearSession вызван (для обратной совместимости)');
    if (kIsWeb) {
      _memoryAccessToken = null;
    } else {
      await _prefs.remove('legacy_access_token');
      await _prefs.remove('legacy_refresh_token');
      await _prefs.remove('legacy_expires_at');
    }
  }
}
