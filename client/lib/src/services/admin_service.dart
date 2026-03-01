import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/api/api_config.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart';
import 'http_client.dart';

class AdminService {
  final ApiConfig _config;
  final AuthStorage _auth;
  final http.Client _httpClient;

  AdminService(this._config, this._auth, [http.Client? httpClient])
      : _httpClient = httpClient ?? http.Client();

  /// Проверяет, является ли текущий пользователь администратором
  /// путем попытки доступа к административному эндпоинту
  Future<bool> isAdmin() async {
    try {
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);

      // Попытка получить статистику администратора
      final response = await client.get(
        Uri.parse('${_config.apiBase}/admin/stats'),
      );

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
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);
      final response = await client.get(
        Uri.parse('${_config.apiBase}/admin/stats'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);
      final response = await client.get(
        Uri.parse('${_config.apiBase}/admin/users?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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
      final client = AuthenticatedHttpClient(_httpClient, _config, _auth);
      final response = await client.get(
        Uri.parse('${_config.apiBase}/admin/audit?page=$page&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['logs'] ?? [];
      } else {
        throw Exception('Get audit logs failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get audit logs error: $e');
    }
  }
}
