import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_config.dart';
import '../../../../core/api/api_client.dart';
import '../models/admin_user_dto.dart';

/// Удалённый источник данных для админ-панели
class AdminRemoteDataSource {
  final ApiConfig config;
  final ApiClient apiClient;

  AdminRemoteDataSource({
    required this.config,
    required this.apiClient,
  });

  /// Получает статистику админ-панели
  Future<Map<String, dynamic>> getStats() async {
    final response = await apiClient.get('/admin/stats');
    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;
    return data['data'] as Map<String, dynamic>? ?? data;
  }

  /// Получает список пользователей с пагинацией
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 50,
    Map<String, dynamic>? filters,
  }) async {
    final token = await storage.readAccessToken();
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (filters != null) ...filters,
    };

    final uri = Uri.parse('${config.apiBase}/admin/users')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // API возвращает { success: true, data: { users: [...], pagination: {...} } }
      final dataPayload = data['data'] as Map<String, dynamic>? ?? data;
      return dataPayload;
    }

    throw _handleError(response);
  }

  /// Получает детали пользователя по ID
  Future<AdminUserDto> getUserById(String userId) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}/admin/users/$userId');

    final response = await http.get(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userData = data['data'] as Map<String, dynamic>? ?? data['user'] as Map<String, dynamic>? ?? data;
      return AdminUserDto.fromJson(userData);
    }

    throw _handleError(response);
  }

  /// Обновляет роль пользователя
  Future<void> updateUserRole(String userId, String role) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}/admin/users/$userId/role');

    final response = await http.patch(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _handleError(response);
    }
  }

  /// Блокирует/разблокирует пользователя
  Future<void> blockUser(String userId, bool blocked) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}/admin/users/$userId/block');

    final response = await http.patch(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'is_active': !blocked}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _handleError(response);
    }
  }

  /// Сбрасывает пароль пользователя
  Future<void> resetUserPassword(String userId) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}/admin/users/$userId/reset-password');

    final response = await http.post(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _handleError(response);
    }
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String userId) async {
    final token = await storage.readAccessToken();
    final uri = Uri.parse('${config.apiBase}/admin/users/$userId');

    final response = await http.delete(
      uri,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw _handleError(response);
    }
  }

  /// Обрабатывает ошибки HTTP
  Exception _handleError(http.Response response) {
    final statusCode = response.statusCode;
    String message = 'Ошибка сервера';

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      message = body?['message'] as String? ?? body?['error'] as String? ?? message;
    } catch (_) {
      // Игнорируем ошибки парсинга
    }

    switch (statusCode) {
      case 401:
        return AdminAuthException('Требуется авторизация');
      case 403:
        return AdminAuthException('Недостаточно прав');
      case 404:
        return AdminNotFoundException('Ресурс не найден');
      case 400:
        return AdminApiException(message);
      default:
        return AdminApiException('Ошибка: $statusCode');
    }
  }
}

/// Исключение авторизации в админ-панели
class AdminAuthException implements Exception {
  final String message;
  const AdminAuthException(this.message);

  @override
  String toString() => 'AdminAuthException: $message';
}

/// Исключение не найдено
class AdminNotFoundException implements Exception {
  final String message;
  const AdminNotFoundException(this.message);

  @override
  String toString() => 'AdminNotFoundException: $message';
}

/// Исключение API
class AdminApiException implements Exception {
  final String message;
  const AdminApiException(this.message);

  @override
  String toString() => 'AdminApiException: $message';
}
