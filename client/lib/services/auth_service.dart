import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/token_pair.dart';
import 'auth_storage.dart';

class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final http.Client httpClient;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  AuthService({
    required this.apiBase,
    required this.authStorage,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Future<TokenPair> loginWithGoogle() async {
    try {
      // 1. Запускаем нативное окно входа
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Пользователь нажал "Назад" / отменил вход
        throw Exception('Вход отменен пользователем');
      }

      // 2. Получаем токены (нам нужен idToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Не удалось получить Google ID Token');
      }

      // 3. Отправляем idToken на наш Go-бэкенд
      final response = await httpClient.post(
        Uri.parse('$apiBase/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка Google Sign-In: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);

      // 4. Сохраняем сессию
      await authStorage.writeTokenPair(tokens);

      return tokens;
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
    final response = await httpClient.post(
      Uri.parse('$apiBase/auth/validate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Токен недействителен');
    }

    // Токен действителен, возвращаем его
    final data = jsonDecode(response.body);
    final user = data['user'];
    
    // Возвращаем текущий токен, так как он уже валидный
    final refreshToken = await authStorage.readRefreshToken();
    final expiresAt = await authStorage.readExpiresAt();
    
    return TokenPair(
      accessToken: token,
      refreshToken: refreshToken ?? '',
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(hours: 24)),
    );
  }

  // Обнови метод logout
  Future<void> logout({bool allDevices = false}) async {
    await _googleSignIn.signOut(); // Важно добавить это
    // Дополнительно можно вызвать logout на бэкенде
    final currentToken = await authStorage.readAccessToken();
    if (currentToken != null) {
      try {
        await httpClient.post(
          Uri.parse('$apiBase/auth/logout'),
          headers: {
            'Authorization': 'Bearer $currentToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'all_devices': allDevices}),
        );
      } catch (e) {
        // Игнорируем ошибки при logout
      }
    }
    await authStorage.clearSession();
  }
}