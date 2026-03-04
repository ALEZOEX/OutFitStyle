import 'package:web/web.dart' as web;
import '../models/token_pair.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart' as core;

/// Веб-версия хранилища аутентификации
/// Security: Access token хранится ТОЛЬКО в памяти (не в localStorage), refresh token — в httpOnly cookie
/// Это защищает от XSS атак — токен нельзя украсть через JavaScript
class AuthStorage implements core.AuthStorage {
  // Используем обфусцированные ключи только для expiresAt (не секрет)
  static const _kExpiresAt = 'os_e6w2y8z0';  // obfuscated: expires_at

  final web.Storage _localStorage;

  // Security: Access token храним только в памяти
  String? _accessTokenInMemory;
  DateTime? _expiresAtInMemory;

  AuthStorage() : _localStorage = web.window.localStorage;

  /// Сохраняет пару токенов
  /// Security: Access token — только в памяти, refresh token — в httpOnly cookie (устанавливается сервером)
  @override
  Future<void> writeTokenPair(TokenPair pair) async {
    print('[AuthStorage Web] Сохраняем токен: access=in_memory, refresh=httpOnly_cookie');
    try {
      // Access token — только в памяти
      _accessTokenInMemory = pair.accessToken;
      _expiresAtInMemory = pair.expiresAt;

      // ExpiresAt — в localStorage (не секрет, можно для проверки истечения)
      _localStorage.setItem(_kExpiresAt, pair.expiresAt.toIso8601String());

      // Refresh token НЕ сохраняем здесь — он приходит в httpOnly cookie от сервера
      print('[AuthStorage Web] Токен сохранён успешно (access в памяти, refresh в cookie)');
    } catch (e) {
      print('[AuthStorage Web] Ошибка сохранения токена: $e');
      rethrow;
    }
  }

  /// Читает access токен из памяти
  @override
  Future<String?> readAccessToken() async {
    return _accessTokenInMemory;
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
  /// Access token — из памяти, refresh token — null (cookie)
  @override
  Future<TokenPair?> readTokenPair() async {
    try {
      final access = _accessTokenInMemory;
      final expiresAtStr = _localStorage.getItem(_kExpiresAt);

      print('[AuthStorage Web] Чтение токена: access=${access != null ? "present" : "null"}');

      if (access == null) {
        print('[AuthStorage Web] Access token не найден в памяти');
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
      // Очищаем access token из памяти
      _accessTokenInMemory = null;
      _expiresAtInMemory = null;

      // Очищаем expiresAt из localStorage
      _localStorage.removeItem(_kExpiresAt);

      // Очищаем refresh token cookie (устанавливаем expired cookie)
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
