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

  /// Web OAuth 2.0 Client ID для браузера (должен совпадать с GOOGLE_CLIENT_ID на бэкенде)
  static const _webClientId = '242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com';

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
         clientId: _webClientId,
         // Server client ID для верификации на бэкенде
         serverClientId: _webClientId,
       ),
       _firebaseAuth = FirebaseAuth.instance;

  Future<TokenPair> loginWithGoogle() async {
    try {
      print('[GoogleSignIn Web] Начало входа через Google');

      // 1. Используем GoogleSignIn для получения Google ID Token
      // Это критично: Firebase Auth getIdToken() возвращает Firebase токен,
      // а не Google ID Token, который ожидает бэкенд
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('[GoogleSignIn Web] Вход отменён пользователем');
        throw Exception('Вход отменён пользователем');
      }

      print('[GoogleSignIn Web] Пользователь авторизован: ${googleUser.email}');

      // 2. Получаем Google ID Token (не Firebase!)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      print('[GoogleSignIn Web] Google ID Token получен: ${idToken != null ? "yes" : "no"}');

      if (idToken == null || idToken.isEmpty) {
        print('[GoogleSignIn Web] Google ID Token пуст');
        throw Exception('Не удалось получить Google ID Token. Проверьте настройки OAuth в Google Cloud Console.');
      }

      // 3. Отправляем Google ID Token на наш Go-бэкенд
      print('[GoogleSignIn Web] Отправка токена на бэкенд: /api/v1/auth/google');
      
      final response = await _dio.post(
        '/api/v1/auth/google',
        data: {'id_token': idToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('[GoogleSignIn Web] Ответ от бэкенда: status=${response.statusCode}');

      if (response.statusCode != 200) {
        print('[GoogleSignIn Web] Ошибка бэкенда: ${response.statusCode} - ${response.data}');
        throw Exception(
            'Ошибка Google Sign-In: ${response.statusCode} - ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      print('[GoogleSignIn Web] Данные ответа: ${data.keys.join(", ")}');

      // Проверяем, что 'tokens' существует и является Map
      if (data['tokens'] != null && data['tokens'] is Map<String, dynamic>) {
        final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);
        print('[GoogleSignIn Web] Токены получены: access=${_maskToken(tokens.accessToken)}');

        // 4. Сохраняем сессию в localStorage
        await authStorage.writeTokenPair(tokens);
        print('[GoogleSignIn Web] Сессия сохранена');

        return tokens;
      } else {
        print('[GoogleSignIn Web] Неверный формат ответа: tokens=${data['tokens']}');
        throw Exception('Неверный формат ответа от сервера: отсутствуют токены');
      }
    } on FirebaseAuthException catch (e) {
      // Если ошибка Firebase Auth
      print('[GoogleSignIn Web] Firebase Auth error: ${e.message}');
      await _googleSignIn.signOut();
      throw Exception('Ошибка Firebase Auth: ${e.message}');
    } on DioException catch (e) {
      // Ошибки сети
      print('[GoogleSignIn Web] Dio error: ${e.type} - ${e.message}');
      await _googleSignIn.signOut();
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка сети: ${e.message}');
    } on Exception catch (e) {
      // Ошибки popup blocker или других браузерных ограничений
      print('[GoogleSignIn Web] Browser error: $e');
      await _googleSignIn.signOut();
      throw Exception('Браузер заблокировал окно входа. Разрешите popup для этого сайта.');
    } catch (e) {
      // Если другая ошибка
      print('[GoogleSignIn Web] Unexpected error: $e');
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

  /// Маскирует токен для логирования
  String _maskToken(String token) {
    if (token.length < 10) return '***';
    return '${token.substring(0, 5)}...${token.substring(token.length - 5)}';
  }
}
