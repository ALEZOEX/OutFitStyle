import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/ui_states.dart';

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController();
});

class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(const AdminState());

  Future<Map<String, dynamic>> getStats() async {
    // Заглушка для получения статистики
    // В реальном приложении здесь будет вызов API
    return {
      'totalUsers': 100,
      'activeUsers': 75,
      'totalRecommendations': 500,
      'totalWardrobeItems': 2000,
    };
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    // Заглушка для получения пользователей
    // В реальном приложении здесь будет вызов API
    return [
      {
        'id': '1',
        'email': 'admin@example.com',
        'name': 'Admin User',
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'email': 'user@example.com',
        'name': 'Regular User',
        'role': 'user',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  Future<void> loadStats() async {
    // Load admin stats
  }

  Future<void> loadUsers() async {
    // Load users
  }
}
