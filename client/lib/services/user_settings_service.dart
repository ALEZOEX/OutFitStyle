import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../exceptions/api_exceptions.dart';
import '../models/user_settings.dart';
import 'auth_storage.dart';

class UserSettingsService {
  final String baseUrl; 
  final AuthStorage authStorage;
  final http.Client _client;

  UserSettingsService({
    required this.baseUrl,
    required this.authStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Загрузить настройки/профиль пользователя:
  /// GET {baseUrl}/users/{userId}/profile
  Future<UserSettings> fetchSettings() async {
    final token = await authStorage.readAccessToken();
    final userId = await authStorage.readUserId();

    if (token == null || userId == null) {
      throw const ApiException('Пользователь не авторизован');
    }

    final uri = Uri.parse('$baseUrl/users/$userId/profile');

    http.Response resp;
    try {
      resp = await _client
          .get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Если бэк пока не проверяет JWT — это не мешает
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(Duration(seconds: AppConfig.requestTimeout));
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    }

    if (resp.statusCode != 200) {
      throw _buildApiError(resp, 'Ошибка загрузки профиля');
    }

    final decoded = jsonDecode(utf8.decode(resp.bodyBytes));

    // Поддерживаем два формата:
    // 1) чистый объект профиля: { ... }
    // 2) обёртка: { "data": { ... }, "meta": { ... } }
    final Map<String, dynamic> data;
    if (decoded is Map<String, dynamic> && decoded['data'] is Map) {
      data = decoded['data'] as Map<String, dynamic>;
    } else if (decoded is Map<String, dynamic>) {
      data = decoded;
    } else {
      throw const ApiException('Неожиданный формат ответа профиля');
    }

    return UserSettings.fromJson(data);
  }

  /// Обновить профиль пользователя:
  /// PUT {baseUrl}/users/{settings.userId}/profile
  Future<UserSettings> updateSettings(UserSettings settings) async {
    final token = await authStorage.readAccessToken();
    final userId = await authStorage.readUserId();

    if (token == null || userId == null) {
      throw const ApiException('Пользователь не авторизован');
    }

    final uri = Uri.parse('$baseUrl/users/${settings.userId}/profile');

    http.Response resp;
    try {
      resp = await _client
          .put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(settings.toJson()),
      )
          .timeout(Duration(seconds: AppConfig.requestTimeout));
    } on TimeoutException {
      throw const NetworkException('Превышено время ожидания от сервера.');
    } on http.ClientException catch (e) {
      throw NetworkException('Ошибка сети: ${e.message}');
    }

    if (resp.statusCode != 200) {
      throw _buildApiError(resp, 'Ошибка сохранения профиля');
    }
    return settings;
  }

  ApiException _buildApiError(http.Response resp, String prefix) {
    String message = prefix;

    if (resp.body.isNotEmpty) {
      try {
        final body = jsonDecode(utf8.decode(resp.bodyBytes));
        if (body is Map<String, dynamic>) {
          message = body['error']?.toString() ??
              body['message']?.toString() ??
              '$prefix: ${resp.statusCode}';
        } else {
          message = '$prefix: ${utf8.decode(resp.bodyBytes).trim()}';
        }
      } catch (_) {
        message = '$prefix: ${utf8.decode(resp.bodyBytes).trim()}';
      }
    }

    return ApiServiceException(
      message,
      resp.statusCode,
      resp.request?.url.path ?? '',
    );
  }
}