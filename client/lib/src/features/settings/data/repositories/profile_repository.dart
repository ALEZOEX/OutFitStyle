import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';

/// Репозиторий для работы с профилем пользователя
///
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/users/me - получение профиля
/// - PUT /api/v1/users/profile - обновление профиля
/// - DELETE /api/v1/users/account - удаление аккаунта
/// - POST /api/v1/users/avatar - загрузка аватара
class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Получить профиль текущего пользователя
  ///
  /// Endpoint: GET /api/v1/users/me
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get('/api/v1/users/me');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        return userData;
      } else {
        throw ProfileException(
          'Ошибка получения профиля: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка получения профиля: $e');
    }
  }

  /// Обновить профиль пользователя
  ///
  /// [name] - новое имя
  /// [email] - новый email
  /// [bio] - биография
  /// [avatarUrl] - URL аватара
  ///
  /// Endpoint: PUT /api/v1/users/profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (bio != null) body['bio'] = bio;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final response = await _apiClient.put(
        '/api/v1/users/profile',
        data: body,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        return userData;
      } else {
        throw ProfileException(
          'Ошибка обновления профиля: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка обновления профиля: $e');
    }
  }

  /// Удалить аккаунт пользователя
  ///
  /// [password] - пароль для подтверждения
  /// [reason] - причина удаления (опционально)
  /// [feedback] - обратная связь (опционально)
  ///
  /// Endpoint: DELETE /api/v1/users/account
  Future<void> deleteAccount({
    required String password,
    String? reason,
    String? feedback,
  }) async {
    try {
      final body = <String, dynamic>{'password': password};

      if (reason != null) body['reason'] = reason;
      if (feedback != null) body['feedback'] = feedback;

      final response = await _apiClient.delete('/api/v1/users/account');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ProfileException(
          'Ошибка удаления аккаунта: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка удаления аккаунта: $e');
    }
  }

  /// Загрузить аватар
  ///
  /// [avatarUrl] - URL аватара
  ///
  /// Endpoint: POST /api/v1/users/avatar
  Future<Map<String, dynamic>> uploadAvatar(String avatarUrl) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/users/avatar',
        data: {'avatar_url': avatarUrl},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        return userData;
      } else {
        throw ProfileException(
          'Ошибка загрузки аватара: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка загрузки аватара: $e');
    }
  }

  /// Загрузить аватар из файла
  ///
  /// [avatarFile] - файл аватара (Image)
  ///
  /// Endpoint: POST /api/v1/users/avatar (multipart/form-data)
  Future<Map<String, dynamic>> uploadAvatarFile(File avatarFile) async {
    try {
      final fileName = path.basename(avatarFile.path);
      final mediaType = _getMediaType(fileName);

      // Создаем multipart запрос
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      // Создаем отдельный Dio для multipart запроса с авторизацией
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      // Добавляем токен авторизации через ApiConfig
      final token = await ApiConfig.getAccessToken();
      if (token != null && token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post('/api/v1/users/avatar', data: formData);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>? ?? data;
        return userData;
      } else {
        throw ProfileException(
          'Ошибка загрузки аватара: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка загрузки аватара: $e');
    }
  }

  /// Получить тип контента по расширению файла
  MediaType _getMediaType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'octet-stream');
    }
  }

  /// Получить предпочтения пользователя
  ///
  /// Endpoint: GET /api/v1/users/preferences
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _apiClient.get('/api/v1/users/preferences');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prefData = data['preferences'] as Map<String, dynamic>? ?? data;
        return prefData;
      } else {
        throw ProfileException(
          'Ошибка получения предпочтений: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка получения предпочтений: $e');
    }
  }

  /// Обновить предпочтения пользователя
  ///
  /// [preferences] - новые предпочтения
  ///
  /// Endpoint: PUT /api/v1/users/preferences
  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/users/preferences',
        data: preferences,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final prefData = data['preferences'] as Map<String, dynamic>? ?? data;
        return prefData;
      } else {
        throw ProfileException(
          'Ошибка обновления предпочтений: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      if (e is ProfileException) rethrow;
      throw ProfileException('Ошибка обновления предпочтений: $e');
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ProfileException('Превышено время ожидания. Проверьте соединение.');
    }

    if (e.type == DioExceptionType.connectionError) {
      throw ProfileException('Нет соединения с интернетом.');
    }

    final statusCode = e.response?.statusCode;
    final errorMessage = _extractErrorMessage(e.response?.data);

    switch (statusCode) {
      case 401:
        throw ProfileException('Требуется авторизация');
      case 403:
        throw ProfileException('Нет доступа');
      case 404:
        throw ProfileException('Профиль не найден');
      case 409:
        throw ProfileException('Email уже используется');
      case 422:
        throw ProfileException(errorMessage ?? 'Неверные данные');
      case 500:
        throw ProfileException('Ошибка сервера');
      default:
        throw ProfileException('Ошибка сети: ${e.message}');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }
}

/// Исключение репозитория профиля
class ProfileException implements Exception {
  final String message;

  const ProfileException(this.message);

  @override
  String toString() => 'ProfileException: $message';
}
