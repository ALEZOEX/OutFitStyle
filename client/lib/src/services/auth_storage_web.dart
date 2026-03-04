import 'package:web/web.dart' as web;
import '../models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart' as core;

/// Веб-версия хранилища аутентификации
/// Security: Access token хранится в localStorage, refresh token — в httpOnly cookie
class AuthStorage implements core.AuthStorage {
  // Используем обфусцированные ключи для безопасности
  static const _kAccessToken = 'os_at_l5g8k2';  // access token в localStorage
  static const _kExpiresAt = 'os_e6w2y8z0';      // obfuscated: expires_at

  final web.Storage _localStorage;

  AuthStorage() : _localStorage = web.window.localStorage;

  /// Сохраняет пару токенов
  /// Security: Access token — в localStorage, refresh token — в httpOnly cookie (устанавливается сервером)
  @override
  Future<void> writeTokenPair(TokenPair pair) async {
    print('[AuthStorage Web] Сохраняем токен: access=localStorage, refresh=httpOnly_cookie');
    try {
      // Access token — в localStorage
      _localStorage.setItem(_kAccessToken, pair.accessToken);

      // ExpiresAt — в localStorage (не секрет, можно для проверки истечения)
      _localStorage.setItem(_kExpiresAt, pair.expiresAt.toIso8601String());

      // Refresh token НЕ сохраняем здесь — он приходит в httpOnly cookie от сервера
      // Cookie устанавливается через заголовок Set-Cookie с флагами:
      // - HttpOnly (недоступен для JavaScript)
      // - Secure (только HTTPS)
      // - SameSite=Strict (защита от CSRF)

      print('[AuthStorage Web] Токен сохранён успешно (access в localStorage, refresh в cookie)');
    } catch (e) {
      print('[AuthStorage Web] Ошибка сохранения токена: $e');
      rethrow;
    }
  }

  /// Читает access токен из localStorage
  @override
  Future<String?> readAccessToken() async {
    return _localStorage.getItem(_kAccessToken);
  }

  /// Читает refresh токен
  /// Примечание: refresh token в httpOnly cookie недоступен для JavaScript
  /// Refresh отправляется браузером автоматически с каждым запросом
  @override
  Future<String?> readRefreshToken() async {
    // Security: refresh token в httpOnly cookie — JavaScript не имеет доступа
    // Backend должен сам извлекать refresh token из cookie
    // Возвращаем null, клиент должен использовать cookie-based refresh
    return null;
  }

  /// Читает пару токенов
  /// Access token — из localStorage, refresh token — null (cookie)
  @override
  Future<TokenPair?> readTokenPair() async {
    try {
      final access = _localStorage.getItem(_kAccessToken);
      final expiresAtStr = _localStorage.getItem(_kExpiresAt);

      print('[AuthStorage Web] Чтение токена: access=${access != null ? "present" : "null"}');

      if (access == null) {
        print('[AuthStorage Web] Access token не найден в localStorage');
        return null;
      }

      DateTime? expiresAt;
      if (expiresAtStr != null) {
        expiresAt = DateTime.tryParse(expiresAtStr);
      }

      return TokenPair(
        accessToken: access,
        refreshToken: '', // Refresh token в cookie, недоступен для JS
        expiresAt: expiresAt ?? DateTime.now().add(const Duration(minutes: 15)),
      );
    } catch (e) {
      print('[AuthStorage Web] Ошибка чтения токенов: $e');
      return null;
    }
  }

  /// Очищает сессию
  @override
  Future<void> clearSession() async {
    try {
      print('[AuthStorage Web] Очистка сессии');
      // Очищаем access token из localStorage
      _localStorage.removeItem(_kAccessToken);

      // Очищаем expiresAt из localStorage
      _localStorage.removeItem(_kExpiresAt);

      // Очищаем refresh token cookie (устанавливаем expired cookie)
      // Cookie будет удалён браузером
      web.document.cookie = 'refresh_token=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/; Secure; SameSite=Strict';

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
}
