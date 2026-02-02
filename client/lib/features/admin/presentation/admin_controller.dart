import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminControllerProvider = StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController();
});

class AdminController extends StateNotifier<AdminState> {
  AdminController() : super(const AdminState());
}

class AdminState {}