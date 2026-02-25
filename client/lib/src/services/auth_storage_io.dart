import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/token_pair.dart';

/// Мобильная версия хранилища аутентификации с использованием FlutterSecureStorage
class AuthStorage {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kExpiresAt = 'expires_at';

  final FlutterSecureStorage _storage;

  AuthStorage() : _storage = const FlutterSecureStorage();

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

  /// Сохраняет пару токенов в защищённое хранилище
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
  Future<String?> readAccessToken() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.accessToken;
  }

  /// Читает refresh токен
  Future<String?> readRefreshToken() async {
    final tokenPair = await readTokenPair();
    return tokenPair?.refreshToken;
  }

  /// Читает пару токенов из защищённого хранилища
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
