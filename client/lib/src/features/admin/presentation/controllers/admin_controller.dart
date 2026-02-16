import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/admin_state.dart';
import '../../../../data/remote/api_client.dart';

/// Контроллер административной панели
class AdminController extends StateNotifier<AdminState> {
  final ApiClient _apiClient;

  AdminController({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const AdminState());

  /// Получить статистику
  Future<Map<String, dynamic>> getStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get('/admin/stats');
      if (response.statusCode == 200) {
        final stats = jsonDecode(response.body) as Map<String, dynamic>;
        state = state.copyWith(
          isLoading: false,
          stats: stats,
        );
        return stats;
      }
      throw AdminException('Не удалось загрузить статистику');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Получить список пользователей
  Future<List<Map<String, dynamic>>> getUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.get('/admin/users');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final users = (data['users'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        state = state.copyWith(
          isLoading: false,
          users: users,
        );
        return users;
      }
      throw AdminException('Не удалось загрузить пользователей');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

/// Исключение админ-контроллера
class AdminException implements Exception {
  final String message;
  const AdminException(this.message);

  @override
  String toString() => 'AdminException: $message';
}