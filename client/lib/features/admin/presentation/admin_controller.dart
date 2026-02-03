import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/ui_states.dart';

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController();
});

class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(const AdminState());

  Future<void> loadStats() async {
    // Load admin stats
  }

  Future<void> loadUsers() async {
    // Load users
  }
}
