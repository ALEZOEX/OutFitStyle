import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/states/admin_state.dart';

class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(AdminInitial());

  Future<Map<String, dynamic>> getStats() async {
    // In a real implementation, we would fetch stats from an API
    // For now, return mock data
    return {
      'totalUsers': 1250,
      'activeUsers': 890,
      'totalRecommendations': 5432,
      'totalWardrobeItems': 12890,
    };
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    // In a real implementation, we would fetch users from an API
    // For now, return mock data
    return [
      {
        'id': '1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'joinDate': '2023-01-15',
        'isActive': true,
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'joinDate': '2023-02-20',
        'isActive': true,
      },
    ];
  }
}