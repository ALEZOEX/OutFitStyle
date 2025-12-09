import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Модель сессии аутентификации.
class AuthSession {
  final int userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const AuthSession({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class AuthStorage {
  // Можно при желании настроить опции для платформ (шифрование, accessibility и т.п.)
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyTokenExpiresAt = 'token_expires_at';

  /// Старые методы — оставляем для совместимости

  /// Прочитать сохранённый access token (JWT/opaque) или null.
  Future<String?> readAccessToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  /// Прочитать сохранённый userId (int) или null.
  Future<int?> readUserId() async {
    final raw = await _storage.read(key: _keyUserId);
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  /// Сохранить текущую сессию пользователя (минимальный вариант).
  Future<void> saveSession({
    required int userId,
    required String accessToken,
  }) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keyAccessToken, value: accessToken);
  }

  /// Очистить все сохранённые данные (НЕ только auth).
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  // -----------------------------
  // Новые, более удобные методы
  // -----------------------------

  /// Прочитать полную сессию (userId + accessToken + refreshToken + expiresAt) или null.
  Future<AuthSession?> readSession() async {
    final userIdStr = await _storage.read(key: _keyUserId);
    final accessToken = await _storage.read(key: _keyAccessToken);

    if (userIdStr == null || accessToken == null) {
      return null;
    }

    final userId = int.tryParse(userIdStr);
    if (userId == null) {
      // данные повреждены — очищаем только auth-ключи
      await clearSession();
      return null;
    }

    final refreshToken = await _storage.read(key: _keyRefreshToken);
    final expiresAtStr = await _storage.read(key: _keyTokenExpiresAt);
    DateTime? expiresAt;
    if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
      try {
        expiresAt = DateTime.parse(expiresAtStr);
      } catch (_) {
        expiresAt = null;
      }
    }

    return AuthSession(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  /// Проверить, есть ли вообще сохранённая сессия (без проверки истечения).
  Future<bool> hasSession() async {
    final session = await readSession();
    return session != null;
  }

  /// Проверить, есть ли активная (не истёкшая) сессия.
  ///
  /// Если expiresAt не задан — считаем, что токен активен и проверяем только наличие userId + accessToken.
  Future<bool> hasActiveSession() async {
    final session = await readSession();
    if (session == null) return false;
    if (session.expiresAt == null) return true;
    return !session.isExpired;
  }

  /// Сохранить полную сессию (с поддержкой refreshToken и expiresAt).
  ///
  /// expiresAt — момент истечения accessToken (если backend его отдаёт).
  Future<void> saveFullSession({
    required int userId,
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _keyUserId, value: userId.toString());
    await _storage.write(key: _keyAccessToken, value: accessToken);

    if (refreshToken != null) {
      await _storage.write(
        key: _keyRefreshToken,
        value: refreshToken,
      );
    } else {
      await _storage.delete(key: _keyRefreshToken);
    }

    if (expiresAt != null) {
      await _storage.write(
        key: _keyTokenExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    } else {
      await _storage.delete(key: _keyTokenExpiresAt);
    }
  }

  /// Обновить только accessToken и, при необходимости, expiresAt.
  ///
  /// Удобно использовать при обновлении токена по refreshToken.
  Future<void> updateAccessToken({
    required String accessToken,
    DateTime? expiresAt,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);

    if (expiresAt != null) {
      await _storage.write(
        key: _keyTokenExpiresAt,
        value: expiresAt.toIso8601String(),
      );
    }
  }

  /// Очистить только auth-сессию (не трогая другие возможные ключи в secure storage).
  Future<void> clearSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyTokenExpiresAt);
  }
}