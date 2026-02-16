import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/admin_state.dart';

/// Контроллер административной панели
class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(const AdminState());

  Future<Map<String, dynamic>> getStats() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement stats retrieval
      throw UnimplementedError();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement users retrieval
      throw UnimplementedError();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}