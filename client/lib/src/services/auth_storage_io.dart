import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart' as core;
import 'dart:math' as math;

/// Мобильная версия хранилища аутентификации с использованием FlutterSecureStorage
class AuthStorage implements core.AuthStorage {
  // Используем обфусцированные ключи для безопасности
  static const _kAccessToken = 'os_a7f3c9e1';  // obfuscated: access_token
  static const _kRefreshToken = 'os_b2d8f4a6';  // obfuscated: refresh_token
  static const _kExpiresAt = 'os_c5e1g7h9';      // obfuscated: expires_at

  final FlutterSecureStorage _storage;

  AuthStorage() : _storage = const FlutterSecureStorage(
    // Дополнительные настройки безопасности для Android
    androidOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      preferencesKeyPrefix: 'os_sec_',
    ),
    // Настройки для iOS
    iOSOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> saveToken(TokenPair token) async {
    await writeTokenPair(token);
  }

  @override
  Future<void> saveTokenPair(TokenPair pair) async {
    await writeTokenPair(pair);
  }

  @override
  Future<TokenPair?> getToken() async {
    return readTokenPair();
  }

  @override
  Future<void> clear() async {
    await clearSession();
  }

  /// Сохраняет пару токенов в защищённое хранилище
  @override
  Future<void> writeTokenPair(TokenPair pair) async {
    print('[AuthStorage Mobile] Сохраняем токен: ${_maskToken(pair.accessToken)}');
    try {
      await _storage.write(key: _kAccessToken, value: pair.accessToken);
      await _storage.write(key: _kRefreshToken, value: pair.refreshToken);
      await _storage.write(
          key: _kExpiresAt, value: pair.expiresAt.toIso8601String());
      print('[AuthStorage Mobile] Токен сохранён успешно');
    } catch (e) {
      print('[AuthStorage Mobile] Ошибка сохранения токена: $e');
      rethrow;
    }
  }

  /// Читает access токен
  @override
  Future<String?> readAccessToken() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.accessToken;
  }

  /// Читает refresh токен
  @override
  Future<String?> readRefreshToken() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.refreshToken;
  }

  /// Читает пару токенов из защищённого хранилища
  @override
  Future<TokenPair?> readTokenPair() async {
    try {
      final access = await _storage.read(key: _kAccessToken);
      final refresh = await _storage.read(key: _kRefreshToken);
      final expiresAtStr = await _storage.read(key: _kExpiresAt);

      print('[AuthStorage Mobile] Чтение токена: access=${access != null ? "present" : "null"}, refresh=${refresh != null ? "present" : "null"}');

      if (access == null || refresh == null) {
        print('[AuthStorage Mobile] Токены не найдены');
        return null;
      }

      DateTime? expiresAt;
      if (expiresAtStr != null) {
        expiresAt = DateTime.tryParse(expiresAtStr);
      }

      // Если токен истёк, не очищаем сразу - пусть сервер решит
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        print('[AuthStorage Mobile] Токен истёк: $expiresAt');
      }

      return TokenPair(
        accessToken: access,
        refreshToken: refresh,
        expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 15)),
      );
    } catch (e) {
      print('[AuthStorage Mobile] Ошибка чтения токенов: $e');
      return null;
    }
  }

  /// Очищает сессию из защищённого хранилища
  @override
  Future<void> clearSession() async {
    try {
      print('[AuthStorage Mobile] Очистка сессии');
      await _storage.delete(key: _kAccessToken);
      await _storage.delete(key: _kRefreshToken);
      await _storage.delete(key: _kExpiresAt);
      print('[AuthStorage Mobile] Сессия очищена');
    } catch (e) {
      print('[AuthStorage Mobile] Ошибка очистки сессии: $e');
    }
  }

  /// Читает время истечения токена
  @override
  Future<DateTime?> readExpiresAt() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.expiresAt;
  }

  /// Маскирует токен для логирования
  String _maskToken(String token) {
    if (token.length < 10) return '***';
    return '${token.substring(0, 5)}...${token.substring(token.length - 5)}';
  }
}
