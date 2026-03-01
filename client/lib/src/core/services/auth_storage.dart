import 'package:outfitstyle_client/src/models/token_pair.dart';

/// Хранилище токенов аутентификации
abstract class AuthStorage {
  /// Сохранить токен (обёртка)
  Future<void> saveToken(TokenPair token);

  /// Получить токен (обёртка)
  Future<TokenPair?> getToken();

  /// Очистить всё
  Future<void> clear();

  /// Очистить сессию (токены)
  Future<void> clearSession();

  /// Сохранить пару токенов
  Future<void> saveTokenPair(TokenPair pair);

  /// Сохранить пару токенов (алиас)
  Future<void> writeTokenPair(TokenPair pair);

  /// Прочитать access токен
  Future<String?> readAccessToken();

  /// Прочитать refresh токен
  Future<String?> readRefreshToken();

  /// Прочитать пару токенов
  Future<TokenPair?> readTokenPair();

  /// Прочитать время истечения
  Future<DateTime?> readExpiresAt();
}