import 'dart:convert';
import 'package:outfitstyle_client/src/core/api/api_client.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService([ApiClient? apiClient])
      : _apiClient = apiClient ?? ApiClient();

  /// Проверяет, является ли текущий пользователь администратором
  /// путем попытки доступа к административному эндпоинту
  Future<bool> isAdmin() async {
    try {
      // Попытка получить статистику администратора
      final response = await _apiClient.get('/admin/stats');

      // Если запрос успешен (200), значит пользователь администратор
      return response.statusCode == 200;
    } catch (e) {
      // Если произошла ошибка, пользователь не администратор
      return false;
    }
  }

  /// Получает административную статистику
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _apiClient.get('/admin/stats');

      if (response.statusCode == 200) {
        return jsonDecode(response.data);
      } else {
        throw Exception('Get admin stats failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get admin stats error: $e');
    }
  }

  /// Получает список пользователей
  Future<List<dynamic>> getUsers(int page, int limit) async {
    try {
      final response = await _apiClient.get(
        '/admin/users',
        params: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return data['users'] ?? [];
      } else {
        throw Exception('Get users failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get users error: $e');
    }
  }

  /// Получает журнал аудита
  Future<List<dynamic>> getAuditLogs(int page, int limit) async {
    try {
      final response = await _apiClient.get(
        '/admin/audit',
        params: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        return data['logs'] ?? [];
      } else {
        throw Exception('Get audit logs failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get audit logs error: $e');
    }
  }
}
