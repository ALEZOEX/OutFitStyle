import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/session_manager.dart';
import '../../../../domain/states/auth_state.dart';

/// Контроллер аутентификации
///
/// Использует [SessionManager] для всех операций аутентификации через Firebase Auth.
class AuthController extends StateNotifier<AuthState> {
  final SessionManager _sessionManager;

  AuthController({
    required SessionManager sessionManager,
  })  : _sessionManager = sessionManager,
        super(const AuthState());

  /// Выход из системы
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _sessionManager.signOut();
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
      final isAuthed = _sessionManager.isAuthenticated;
      if (isAuthed) {
        final session = _sessionManager.currentUserSession;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: isAuthed,
          user: session != null
              ? {
                  'id': session.uid,
                  'email': session.email,
                  'displayName': session.displayName,
                  'photoUrl': session.photoUrl,
                }
              : null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Вход по email/паролю
  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _sessionManager.signIn(email: email, password: password);
      if (success) {
        final session = _sessionManager.currentUserSession;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: session != null
              ? {
                  'id': session.uid,
                  'email': session.email,
                  'displayName': session.displayName,
                  'photoUrl': session.photoUrl,
                }
              : null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Неверный email или пароль',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Регистрация по email/паролю
  Future<void> registerWithEmail(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _sessionManager.signUp(email, password);
      if (success) {
        // Обновляем displayName после регистрации
        await _sessionManager.updateUserProfile(displayName: name);
        
        final session = _sessionManager.currentUserSession;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: session != null
              ? {
                  'id': session.uid,
                  'email': session.email,
                  'displayName': session.displayName,
                  'photoUrl': session.photoUrl,
                }
              : null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Ошибка регистрации',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}