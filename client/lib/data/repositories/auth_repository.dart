import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../models/tokens.dart';
import '../../services/auth_storage.dart';

class AuthRepository {
  final ApiConfig _config;
  final AuthStorage _storage;

  AuthRepository(this._config, this._storage);

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${_config.apiBase}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pair = TokenPair.fromJson(data);
        await _storage.writeTokenPair(pair);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<void> register({required String name, required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${_config.apiBase}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pair = TokenPair.fromJson(data);
        await _storage.writeTokenPair(pair);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<void> logout() => _storage.clearSession();

  Future<bool> isAuthed() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}