import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/admin_state.dart';

class AdminController extends StateNotifier<AdminState> {
  final Ref _ref;

  AdminController(this._ref) : super(const AdminState.initial());

  Future<Map<String, dynamic>> getStats() async {
    // TODO: Implement stats retrieval
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    // TODO: Implement users retrieval
    throw UnimplementedError();
  }
}