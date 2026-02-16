import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/auth_state.dart';
import '../../../../domain/repositories/i_auth_repository.dart';

/// Контроллер аутентификации
class AuthController extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthState());

  /// Вход с помощью Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement Google Sign-In
      throw UnimplementedError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.logout();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Проверка состояния аутентификации
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isAuthed = await _authRepository.isAuthed();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: isAuthed,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}