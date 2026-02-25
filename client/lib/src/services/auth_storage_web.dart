import 'package:web/web.dart' as web;
import '../models/token_pair.dart';

/// Веб-версия хранилища аутентификации с использованием localStorage
class AuthStorage {
  static const _kAccessToken = 'os_access_token';
  static const _kRefreshToken = 'os_refresh_token';
  static const _kExpiresAt = 'os_expires_at';

  final web.Storage _localStorage = web.window.localStorage;

  /// Сохраняет пару токенов в localStorage
  Future<void> writeTokenPair(TokenPair pair) async {
    print('[AuthStorage Web] Сохраняем токен: ${_maskToken(pair.accessToken)}');
    try {
      _localStorage[_kAccessToken] = pair.accessToken;
      _localStorage[_kRefreshToken] = pair.refreshToken;
      _localStorage[_kExpiresAt] = pair.expiresAt.toIso8601String();
      print('[AuthStorage Web] Токен сохранён успешно');
    } catch (e) {
      print('[AuthStorage Web] Ошибка сохранения токена: $e');
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

  /// Читает пару токенов из localStorage
  Future<TokenPair?> readTokenPair() async {
    try {
      final access = _localStorage[_kAccessToken];
      final refresh = _localStorage[_kRefreshToken];
      final expiresAtStr = _localStorage[_kExpiresAt];

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
  Future<void> clearSession() async {
    try {
      print('[AuthStorage Web] Очистка сессии');
      _localStorage.remove(_kAccessToken);
      _localStorage.remove(_kRefreshToken);
      _localStorage.remove(_kExpiresAt);
      print('[AuthStorage Web] Сессия очищена');
    } catch (e) {
      print('[AuthStorage Web] Ошибка очистки сессии: $e');
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
