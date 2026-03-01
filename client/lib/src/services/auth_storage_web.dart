import 'package:web/web.dart' as web;
import '../models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart' as core;

/// Веб-версия хранилища аутентификации с использованием localStorage
class AuthStorage implements core.AuthStorage {
  // Используем обфусцированные ключи для безопасности
  static const _kAccessToken = 'os_t8x3k9m2';  // obfuscated: access_token
  static const _kRefreshToken = 'os_r5n7p1q4';  // obfuscated: refresh_token
  static const _kExpiresAt = 'os_e6w2y8z0';      // obfuscated: expires_at

  final web.Storage _localStorage;

  AuthStorage() : _localStorage = web.window.localStorage;

  @override
  Future<void> saveToken(TokenPair token) async {
    await writeTokenPair(token);
  }

  @override
  Future<TokenPair?> getToken() async {
    return readTokenPair();
  }

  @override
  Future<void> clear() async {
    await clearSession();
  }

  /// Сохраняет пару токенов в localStorage
  @override
  Future<void> writeTokenPair(TokenPair pair) async {
    print('[AuthStorage Web] Сохраняем токен: ${_maskToken(pair.accessToken)}');
    try {
      _localStorage.setItem(_kAccessToken, pair.accessToken);
      _localStorage.setItem(_kRefreshToken, pair.refreshToken);
      _localStorage.setItem(_kExpiresAt, pair.expiresAt.toIso8601String());
      print('[AuthStorage Web] Токен сохранён успешно');
    } catch (e) {
      print('[AuthStorage Web] Ошибка сохранения токена: $e');
      rethrow;
    }
  }

  /// Алиас для writeTokenPair (совместимость с api_client.dart)
  @override
  Future<void> saveTokenPair(TokenPair pair) async {
    await writeTokenPair(pair);
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

  /// Читает пару токенов из localStorage
  @override
  Future<TokenPair?> readTokenPair() async {
    try {
      final access = _localStorage.getItem(_kAccessToken);
      final refresh = _localStorage.getItem(_kRefreshToken);
      final expiresAtStr = _localStorage.getItem(_kExpiresAt);

      print('[AuthStorage Web] Чтение токена: access=${access != null ? "present" : "null"}, refresh=${refresh != null ? "present" : "null"}');

      if (access == null || refresh == null) {
        print('[AuthStorage Web] Токены не найдены в localStorage');
        return null;
      }

      DateTime? expiresAt;
      if (expiresAtStr != null) {
        expiresAt = DateTime.tryParse(expiresAtStr);
      }

      // Если токен истёк, не очищаем сразу - пусть сервер решит
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        print('[AuthStorage Web] Токен истёк: $expiresAt');
        // Не очищаем сессию автоматически
      }

      return TokenPair(
        accessToken: access,
        refreshToken: refresh,
        expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 15)),
      );
    } catch (e) {
      print('[AuthStorage Web] Ошибка чтения токенов: $e');
      return null;
    }
  }

  /// Очищает сессию из localStorage
  @override
  Future<void> clearSession() async {
    try {
      print('[AuthStorage Web] Очистка сессии');
      _localStorage.removeItem(_kAccessToken);
      _localStorage.removeItem(_kRefreshToken);
      _localStorage.removeItem(_kExpiresAt);
      print('[AuthStorage Web] Сессия очищена');
    } catch (e) {
      print('[AuthStorage Web] Ошибка очистки сессии: $e');
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
