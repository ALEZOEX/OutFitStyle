import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../exceptions/api_exceptions.dart';
import 'auth_storage.dart';

class AuthService {
  final String baseUrl;
  final AuthStorage _authStorage;
  final http.Client _client;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required this.baseUrl,
    required AuthStorage authStorage,
    http.Client? client,
    GoogleSignIn? googleSignIn,
  })  : _authStorage = authStorage,
        _client = client ?? http.Client(),
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email', 'profile']);

  Uri _uri(String path) {
    final b = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$b$p');
  }

  Future<Map<String, dynamic>> _postJson(String path, Map<String, dynamic> body) async {
    final resp = await _client.post(
      _uri(path),
      headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) {
      throw ApiException('Ошибка запроса', resp.body);
    }
    return resp.body.isEmpty ? <String, dynamic>{} : (jsonDecode(resp.body) as Map<String, dynamic>);
  }

  Future<void> _saveSessionFromBackend(Map<String, dynamic> result) async {
    final accessToken = (result['accessToken'] ?? result['access_token']) as String?;
    final refreshToken = (result['refreshToken'] ?? result['refresh_token']) as String?;
    final user = result['user'];

    int? userId;
    if (user is Map<String, dynamic>) {
      final rawId = user['id'];
      if (rawId is num) userId = rawId.toInt();
    }
    if (accessToken == null || userId == null) return;

    await _authStorage.saveFullSession(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: null,
    );
  }

  Future<void> register({required String email, required String password, required String username}) async {
    await _postJson('/auth/register', {'email': email.trim(), 'password': password, 'username': username.trim()});
  }

  Future<void> login({required String email, required String password}) async {
    await _postJson('/auth/login', {'email': email.trim(), 'password': password});
  }

  Future<Map<String, dynamic>> verifyCode(String code) async {
    final result = await _postJson('/auth/verify', {'code': code.trim()});
    await _saveSessionFromBackend(result);
    return result;
  }

  Future<void> requestPasswordReset(String email) async {
    await _postJson('/auth/forgot-password', {'email': email.trim()});
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _postJson('/auth/reset-password', {'token': token.trim(), 'newPassword': newPassword});
  }

  Future<Map<String, dynamic>?> signInWithGoogleAndBackend() async {
    final user = await _googleSignIn.signIn();
    if (user == null) return null;
    final auth = await user.authentication;
    final idToken = auth.idToken;
    if (idToken == null) throw ApiException('Не удалось получить Google idToken', 'idToken is null');

    final result = await _postJson('/auth/google', {'idToken': idToken});
    await _saveSessionFromBackend(result);
    return result;
  }

  Future<void> signOutGoogle() => _googleSignIn.signOut();
  void dispose() => _client.close();
}