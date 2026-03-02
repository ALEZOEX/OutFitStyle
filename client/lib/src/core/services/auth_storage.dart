import 'package:outfitstyle_client/src/models/token_pair.dart';

/// Хранилище токенов аутентификации
abstract class AuthStorage {
  /// Сохранить пару токенов
  Future<void> writeTokenPair(TokenPair pair);

  /// Прочитать access токен
  Future<String?> readAccessToken();

  /// Прочитать refresh токен
  Future<String?> readRefreshToken();

  /// Прочитать пару токенов
  Future<TokenPair?> readTokenPair();

  /// Прочитать время истечения
  Future<DateTime?> readExpiresAt();

  /// Очистить сессию (токены)
  Future<void> clearSession();
}