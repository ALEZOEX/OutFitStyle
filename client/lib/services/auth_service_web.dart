import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Реализация AuthService для Web (с Google Sign-In)
class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final String baseUrl;

  AuthService({required this.baseUrl});

  // ================== Email / Password / Code ==================

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'username': username.trim(),
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Не удалось зарегистрироваться: ${resp.body}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/login');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Ошибка входа: ${resp.body}');
    }
  }

  /// Подтверждаем код и получаем user + accessToken
  Future<Map<String, dynamic>> verifyCode(String code) async {
    final uri = Uri.parse('$baseUrl/auth/verify');

    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code.trim()}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Неверный или просроченный код: ${resp.body}');
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // ================== Google Sign-In (Web) ==================

  Future<String?> _getGoogleIdToken() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // пользователь отменил вход

    final googleAuth = await googleUser.authentication;
    return googleAuth.idToken;
  }

  /// Полный цикл: Google → backend → user + tokens
  Future<Map<String, dynamic>?> signInWithGoogleAndBackend() async {
    final idToken = await _getGoogleIdToken();
    if (idToken == null) {
      return null;
    }

    final uri = Uri.parse('$baseUrl/auth/google');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Google login failed: ${resp.statusCode} ${resp.body}');
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<void> signOutGoogle() => _googleSignIn.signOut();
}