import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import '../models/token_pair.dart';
import 'auth_storage.dart';

/// Сервис аутентификации с поддержкой Google Sign-In
/// Web-версия (без использования dart:io)
class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  AuthService({
    required this.apiBase,
    required this.authStorage,
    Dio? dio,
  }) : _dio = dio ?? Dio(BaseOptions(
         baseUrl: apiBase,
         connectTimeout: const Duration(seconds: 15),
         receiveTimeout: const Duration(seconds: 30),
         headers: {'Content-Type': 'application/json'},
       )),
       _googleSignIn = GoogleSignIn(
         scopes: ['email', 'profile'],
         // Web OAuth 2.0 Client ID для браузера
         clientId: '242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com',
         // Server client ID для верификации на бэкенде
         serverClientId: '242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com',
         // Явно указываем redirect URI
         redirectUri: 'https://app.outfitstyle.ru/',
       ),
       _firebaseAuth = FirebaseAuth.instance;

  Future<TokenPair> loginWithGoogle() async {
    try {
      // 1. Используем Firebase Auth для Google Sign-In на вебе
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // 2. Запускаем вход через Firebase (использует redirect)
      final UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);

      // 3. Получаем ID токен
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Не удалось получить Google ID Token');
      }

      // 4. Отправляем idToken на наш Go-бэкенд
      final response = await _dio.post(
        '/api/v1/auth/google',
        data: {'id_token': idToken},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Ошибка Google Sign-In: ${response.statusCode} - ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      // Проверяем, что 'tokens' существует и является Map
      if (data['tokens'] != null && data['tokens'] is Map<String, dynamic>) {
        final tokens =
            TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);

        // 5. Сохраняем сессию
        await authStorage.writeTokenPair(tokens);

        return tokens;
      } else {
        throw Exception(
            'Неверный формат ответа от сервера: отсутствуют токены');
      }
    } on FirebaseAuthException catch (e) {
      // Если ошибка Firebase Auth
      await _googleSignIn.signOut();
      throw Exception('Ошибка Firebase Auth: ${e.message}');
    } catch (e) {
      // Если другая ошибка
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  Future<TokenPair> silentLogin() async {
    // Проверяем, есть ли сохраненный токен
    final token = await authStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Нет сохраненного токена для silent login');
    }

    // Проверяем валидность токена через наш эндпоинт
    final response = await _dio.post(
      '/api/v1/auth/validate',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Токен недействителен');
    }

    // Возвращаем текущий токен, так как он уже валидный
    final refreshToken = await authStorage.readRefreshToken();
    final expiresAt = await authStorage.readExpiresAt();

    return TokenPair(
      accessToken: token,
      refreshToken: refreshToken ?? '',
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 24)),
    );
  }

  /// Выход из системы
  Future<void> logout({bool allDevices = false}) async {
    await _googleSignIn.signOut();
    // Дополнительно можно вызвать logout на бэкенде
    final currentToken = await authStorage.readAccessToken();
    if (currentToken != null) {
      try {
        await _dio.post(
          '/auth/logout',
          data: {'all_devices': allDevices},
          options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
        );
      } catch (e) {
        // Игнорируем ошибки при logout
      }
    }
    await authStorage.clearSession();
  }
}
