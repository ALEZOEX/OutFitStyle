import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/data/repositories/auth_repository.dart';
import 'package:outfitstyle_client/domain/states/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final result = await _authRepository.login(email, password);
      state = AuthSuccess(result);
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = AuthLoading();
    try {
      final result = await _authRepository.register(email, password, name);
      state = AuthSuccess(result);
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = AuthInitial();
    } catch (e) {
      state = AuthFailure(e.toString());
    }
  }
}