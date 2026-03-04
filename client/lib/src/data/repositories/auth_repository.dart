import 'dart:convert';
import '../../core/api/api_config.dart';
import '../../core/api/api_client.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';
import '../../services/auth_service.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../models/token_pair.dart';

/// Репозиторий аутентификации
class AuthRepository implements IAuthRepository {
  final ApiConfig config;
  final AuthStorage authStorage;
  final ApiClient apiClient;
  final AuthService _authService;

  AuthRepository(this.config, this.authStorage, this.apiClient)
      : _authService = AuthService(
          apiBase: ApiConfig.baseUrl,
          authStorage: authStorage,
          dio: apiClient.raw,
        );

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tokenPair = TokenPair.fromJson(data);
        await authStorage.writeTokenPair(tokenPair);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(String email, String password, String name) async {
    try {
      final response = await apiClient.post(
        '/api/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final tokenPair = TokenPair.fromJson(data);
        await authStorage.writeTokenPair(tokenPair);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final tokens = await authStorage.readTokenPair();
    if (tokens == null) {
      return false;
    }

    // Проверяем, не истёк ли токен
    if (tokens.isExpired) {
      // Пробуем обновить токен
      return refreshToken();
    }

    return true;
  }

  @override
  Future<bool> refreshToken() async {
    try {
      print('[AuthRepository] Refresh токена...');
      final tokens = await authStorage.readTokenPair();
      if (tokens == null) {
        print('[AuthRepository] Нет токенов для refresh');
        return false;
      }

      // Используем /api/v1/auth/refresh
      print('[AuthRepository] Запрос к /api/v1/auth/refresh');
      final response = await apiClient.post(
        '/api/v1/auth/refresh',
        data: {
          'refresh_token': tokens.refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // Сервер возвращает {"tokens": {...}}
        final tokensData = data['tokens'] as Map<String, dynamic>? ?? data;
        final tokenPair = TokenPair.fromJson(tokensData);
        await authStorage.writeTokenPair(tokenPair);
        print('[AuthRepository] Refresh успешен');
        return true;
      }

      print('[AuthRepository] Refresh вернул ${response.statusCode}');
      await authStorage.clearSession();
      return false;
    } catch (e) {
      print('[AuthRepository] Ошибка refresh: $e');
      await authStorage.clearSession();
      return false;
    }
  }

  @override
  Future<bool> isAuthed() => isLoggedIn();

  @override
  Future<String?> getUserId() async {
    try {
      final token = await authStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      // Декодируем JWT токен для получения user_id
      // JWT формат: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Декодируем payload (вторая часть)
      final payload = parts[1];
      // Добавляем padding для корректного base64 декодирования
      final normalized = payload.padRight(
        payload.length + (4 - payload.length % 4) % 4,
        '=',
      );
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded) as Map<String, dynamic>;

      // Пробуем получить user_id из разных возможных полей
      return payloadMap['user_id']?.toString() ??
          payloadMap['sub']?.toString() ??
          payloadMap['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Отправляем запрос на сервер для инвалидации токена
      await apiClient.post('/auth/logout');
    } catch (e) {
      // Игнорируем ошибки, всё равно очищаем сессию локально
    } finally {
      await authStorage.clearSession();
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await apiClient.get('/api/v1/user/me');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await apiClient.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}