import '../models/token_pair.dart';

abstract class AuthStorage {
  Future<void> saveToken(TokenPair token);
  Future<TokenPair?> getToken();
  Future<void> clear();
}