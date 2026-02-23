import 'package:google_sign_in/google_sign_in.dart';
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
         // Web client ID для серверной верификации
         // Для web используется один client ID
         serverClientId: _getServerClientId(),
       );

  /// Получает server client ID для Web
  /// Web использует фиксированный Web OAuth client ID
  static String? _getServerClientId() {
    // Web OAuth client ID из Google Cloud Console
    return '242419520610-9o9n26d2qko4amt6h7g6as7m0t4icpf8.apps.googleusercontent.com';
  }

  Future<TokenPair> loginWithGoogle() async {
    try {
      // 1. Запускаем окно входа
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Пользователь нажал "Назад" / отменил вход
        throw Exception('Вход отменен пользователем');
      }

      // 2. Получаем токены (нам нужен idToken)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Не удалось получить Google ID Token');
      }

      // 3. Отправляем idToken на наш Go-бэкенд
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

        // 4. Сохраняем сессию
        await authStorage.writeTokenPair(tokens);

        return tokens;
      } else {
        throw Exception(
            'Неверный формат ответа от сервера: отсутствуют токены');
      }
    } catch (e) {
      // Если ошибка, разлогиниваем гугл, чтобы в след. раз можно было выбрать аккаунт снова
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
      '/auth/validate',
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
