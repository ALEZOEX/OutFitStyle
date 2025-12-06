import 'dart:convert';
import 'package:http/http.dart' as http;

/// Реализация AuthService для io-платформ (Windows, Android, iOS, macOS, Linux)
/// БЕЗ Google Sign-In. Google-кнопка в UI должна уметь обработать UnsupportedError.
class AuthService {
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

  // ================== Заглушка Google Sign-In ==================

  Future<Map<String, dynamic>?> signInWithGoogleAndBackend() async {
    throw UnsupportedError('Google Sign-In не поддерживается на этой платформе');
  }

  Future<void> signOutGoogle() async {
    // ничего не делаем
  }
}