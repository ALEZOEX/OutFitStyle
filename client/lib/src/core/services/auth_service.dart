import 'package:http/http.dart' as http;
import '../models/token_pair.dart';
import '../storage/auth_storage.dart';

class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final http.Client httpClient;

  AuthService({
    required this.apiBase,
    required this.authStorage,
    required this.httpClient,
  });

  Future<TokenPair?> login(String email, String password) async {
    // TODO: Implement login logic
    throw UnimplementedError();
  }

  Future<TokenPair?> register(String email, String password, String name) async {
    // TODO: Implement registration logic
    throw UnimplementedError();
  }

  Future<void> logout() async {
    await authStorage.clearSession();
  }

  Future<TokenPair?> silentLogin() async {
    // TODO: Implement silent login logic
    throw UnimplementedError();
  }

  Future<bool> validateToken() async {
    // TODO: Implement token validation logic
    throw UnimplementedError();
  }
}