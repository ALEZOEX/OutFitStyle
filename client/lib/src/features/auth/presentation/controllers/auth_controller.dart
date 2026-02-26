import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/auth_state.dart';
import '../../../../domain/repositories/i_auth_repository.dart';

/// Контроллер аутентификации
/// 
/// Использует [IAuthRepository] для всех операций аутентификации.
/// Репозиторий делегирует вызовы в [AuthService], который использует:
/// - Firebase Auth (signInWithPopup) на Web
/// - google_sign_in на мобильных платформах (iOS/Android)
class AuthController extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthController({
    required IAuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState());

  /// Вход с помощью Google
  /// 
  /// Делегирует вызов в [IAuthRepository.signInWithGoogle()],
  /// который использует [AuthService.loginWithGoogle()].
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // AuthService сам определит платформу и использует правильный метод:
      // - Web: firebase_auth.signInWithPopup()
      // - Mobile: google_sign_in.signIn()
      final success = await _authRepository.signInWithGoogle();
      
      if (success) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Ошибка аутентификации через Google',
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

  /// Выход из системы
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // AuthService сам выполнит выход из Firebase Auth / Google Sign-In
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
      if (isAuthed) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: isAuthed,
          user: user,
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
      final success = await _authRepository.login(email, password);
      if (success) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
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
      final success = await _authRepository.register(email, password, name);
      if (success) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
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