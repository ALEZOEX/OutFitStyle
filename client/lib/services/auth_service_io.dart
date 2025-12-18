import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../exceptions/api_exceptions.dart';
import 'auth_storage.dart';

class AuthService {
  final String baseUrl; // ожидается .../api/v1
  final http.Client _client;
  final GoogleSignIn _googleSignIn;
  final AuthStorage _authStorage;

  AuthService({
    required this.baseUrl,
    required AuthStorage authStorage,
    http.Client? client,
    GoogleSignIn? googleSignIn,
  })  : _client = client ?? http.Client(),
        _authStorage = authStorage,
        _googleSignIn =
            googleSignIn ?? GoogleSignIn(scopes: const ['email', 'profile']);

  Uri _buildUri(String path) {
    final normalizedBase =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  String _extractErrorMessage(http.Response resp, String fallback) {
    if (resp.body.isEmpty) return fallback;
    try {
      final body = json.decode(resp.body);
      if (body is Map<String, dynamic>) {
        return body['error']?.toString() ??
            body['message']?.toString() ??
            fallback;
      }
      return resp.body.trim();
    } catch (_) {
      return resp.body.trim().isNotEmpty ? resp.body.trim() : fallback;
    }
  }

  ApiException _apiExceptionFromResponse(http.Response resp, String baseMessage) {
    final msg = _extractErrorMessage(resp, baseMessage);
    return ApiException('$baseMessage: $msg', msg);
  }

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    int expectedStatusCode = 200,
    required String errorContext,
  }) async {
    final uri = _buildUri(path);

    late http.Response resp;
    try {
      resp = await _client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      throw ApiException(
        '$errorContext: проблема с подключением к серверу',
        e.toString(),
      );
    }

    if (resp.statusCode != expectedStatusCode) {
      throw _apiExceptionFromResponse(resp, errorContext);
    }

    if (resp.body.isEmpty) return <String, dynamic>{};

    try {
      final decoded = json.decode(resp.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('$errorContext: некорректный формат ответа сервера', 'Unexpected JSON type');
    } catch (e) {
      throw ApiException('$errorContext: ошибка разбора ответа сервера', e.toString());
    }
  }

  Future<void> _saveSessionFromBackend(Map<String, dynamic> result) async {
    final accessToken = (result['accessToken'] ?? result['access_token']) as String?;
    final refreshToken = (result['refreshToken'] ?? result['refresh_token']) as String?;

    final user = result['user'];
    int? userId;
    if (user is Map<String, dynamic>) {
      final rawId = user['id'] ?? user['user_id'];
      if (rawId is num) userId = rawId.toInt();
      if (rawId is String) userId = int.tryParse(rawId);
    }

    if (accessToken == null || userId == null) return;

    await _authStorage.saveFullSession(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: null,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    await _postJson(
      '/auth/register',
      {'email': email.trim(), 'password': password, 'username': username.trim()},
      expectedStatusCode: 200,
      errorContext: 'Не удалось зарегистрироваться',
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _postJson(
      '/auth/login',
      {'email': email.trim(), 'password': password},
      expectedStatusCode: 200,
      errorContext: 'Ошибка входа',
    );
  }

  Future<Map<String, dynamic>> verifyCode(String code) async {
    final result = await _postJson(
      '/auth/verify',
      {'code': code.trim()},
      expectedStatusCode: 200,
      errorContext: 'Неверный или просроченный код',
    );
    await _saveSessionFromBackend(result);
    return result;
  }

  Future<void> requestPasswordReset(String email) async {
    await _postJson(
      '/auth/forgot-password',
      {'email': email.trim()},
      expectedStatusCode: 200,
      errorContext: 'Не удалось отправить письмо для сброса пароля',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _postJson(
      '/auth/reset-password',
      {'token': token.trim(), 'newPassword': newPassword},
      expectedStatusCode: 200,
      errorContext: 'Не удалось сбросить пароль',
    );
  }

  Future<Map<String, dynamic>?> signInWithGoogleAndBackend() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw ApiException('Не удалось получить ID-токен Google', 'idToken is null');
      }

      final result = await _postJson(
        '/auth/google',
        {'idToken': idToken},
        expectedStatusCode: 200,
        errorContext: 'Ошибка входа через Google',
      );

      await _saveSessionFromBackend(result);
      return result;
    } on MissingPluginException {
      throw UnsupportedError('Google Sign-In не поддерживается на этой платформе');
    } on PlatformException catch (e) {
      throw ApiException('Ошибка Google Sign-In: ${e.message}', e.message ?? 'PlatformException');
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  void dispose() => _client.close();
}