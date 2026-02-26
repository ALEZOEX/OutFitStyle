import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import '../models/token_pair.dart';
import 'auth_storage.dart';

/// Сервис аутентификации с поддержкой Google Sign-In через Firebase Auth
/// Web-версия: используется нативный Firebase Auth signInWithPopup
/// 
/// Преимущества перед google_sign_in:
/// - Не требует настройки redirect_uri в Google Cloud Console
/// - Firebase сам управляет OAuth flow
/// - Проще код и надёжнее работает на Flutter Web
class AuthService {
  final String apiBase;
  final AuthStorage authStorage;
  final Dio _dio;
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
       _firebaseAuth = FirebaseAuth.instance;

  /// Вход через Google с использованием Firebase Auth Popup
  /// 
  /// Flow:
  /// 1. Firebase открывает popup для Google OAuth
  /// 2. Получаем ID Token из Firebase UserCredential
  /// 3. Отправляем ID Token на бэкенд для верификации
  /// 4. Получаем JWT токены приложения и сохраняем сессию
  Future<TokenPair> loginWithGoogle() async {
    try {
      print('[Firebase Auth Web] Начало входа через Google (signInWithPopup)');

      // 1. Создаём Google Auth Provider с нужными скоупами
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      // 2. Открываем popup для входа через Google
      // Firebase сам управляет OAuth flow, redirect_uri не требуется
      final UserCredential credential = await _firebaseAuth.signInWithPopup(provider);

      final User? user = credential.user;
      if (user == null) {
        print('[Firebase Auth Web] Вход отменён пользователем');
        throw Exception('Вход отменён пользователем');
      }

      print('[Firebase Auth Web] Пользователь авторизован: ${user.email}');

      // 3. Получаем Google ID Token из Firebase credential
      // Это Google OAuth токен, который бэкенд может верифицировать
      final String? idToken = await user.getIdToken();
      
      // Для верификации на бэкенде нужен именно Google ID Token,
      // а не Firebase ID Token. Получаем его из credential
      final AuthCredential? googleCredential = credential.credential;
      String? googleIdToken;

      if (googleCredential is OAuthCredential) {
        googleIdToken = googleCredential.idToken;
      }
      
      // Fallback: если не удалось получить Google ID Token из credential,
      // используем Firebase ID Token (бэкенд должен уметь верифицировать оба)
      final tokenForBackend = googleIdToken ?? idToken;

      print('[Firebase Auth Web] ID Token получен: ${tokenForBackend != null ? "yes" : "no"}');

      if (tokenForBackend == null || tokenForBackend.isEmpty) {
        print('[Firebase Auth Web] ID Token пуст');
        throw Exception('Не удалось получить ID Token');
      }

      // 4. Отправляем ID Token на наш Go-бэкенд для верификации
      print('[Firebase Auth Web] Отправка токена на бэкенд: /api/v1/auth/google');

      final response = await _dio.post(
        '/api/v1/auth/google',
        data: {'id_token': tokenForBackend},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      print('[Firebase Auth Web] Ответ от бэкенда: status=${response.statusCode}');

      if (response.statusCode != 200) {
        print('[Firebase Auth Web] Ошибка бэкенда: ${response.statusCode} - ${response.data}');
        throw Exception(
            'Ошибка Google Sign-In: ${response.statusCode} - ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;
      print('[Firebase Auth Web] Данные ответа: ${data.keys.join(", ")}');

      // Проверяем, что 'tokens' существует и является Map
      if (data['tokens'] != null && data['tokens'] is Map<String, dynamic>) {
        final tokens = TokenPair.fromJson(data['tokens'] as Map<String, dynamic>);
        print('[Firebase Auth Web] Токены получены: access=${_maskToken(tokens.accessToken)}');

        // 5. Сохраняем сессию в localStorage
        await authStorage.writeTokenPair(tokens);
        print('[Firebase Auth Web] Сессия сохранена');

        return tokens;
      } else {
        print('[Firebase Auth Web] Неверный формат ответа: tokens=${data['tokens']}');
        throw Exception('Неверный формат ответа от сервера: отсутствуют токены');
      }
    } on FirebaseAuthException catch (e) {
      // Ошибки Firebase Auth
      print('[Firebase Auth Web] Firebase Auth error: ${e.code} - ${e.message}');
      throw _mapFirebaseAuthException(e);
    } on DioException catch (e) {
      // Ошибки сети
      print('[Firebase Auth Web] Dio error: ${e.type} - ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Превышено время ожидания ответа от сервера');
      }
      throw Exception('Ошибка сети: ${e.message}');
    } on FirebaseException catch (e) {
      // Ошибки Firebase
      print('[Firebase Auth Web] Firebase error: ${e.code} - ${e.message}');
      throw Exception('Ошибка Firebase: ${e.message}');
    } on Exception catch (e) {
      // Ошибки popup blocker или других браузерных ограничений
      print('[Firebase Auth Web] Browser error: $e');
      throw Exception('Браузер заблокировал окно входа. Разрешите popup для этого сайта.');
    } catch (e) {
      // Если другая ошибка
      print('[Firebase Auth Web] Unexpected error: $e');
      rethrow;
    }
  }

  /// Маппинг Firebase Auth исключений в понятные сообщения
  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'popup-closed-by-user':
        return 'Вход отменён пользователем';
      case 'popup-blocked':
        return 'Браузер заблокировал popup. Разрешите всплывающие окна для этого сайта.';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету.';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже.';
      case 'invalid-credential':
        return 'Неверные учётные данные.';
      default:
        return 'Ошибка входа: ${e.message}';
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
    // Выход из Firebase Auth
    await _firebaseAuth.signOut();
    
    // Дополнительно можно вызвать logout на бэкенде для инвалидации токенов
    final currentToken = await authStorage.readAccessToken();
    if (currentToken != null) {
      try {
        await _dio.post(
          '/api/v1/auth/logout',
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
