import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../domain/states/auth_state.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../data/remote/api_client.dart';

/// Контроллер аутентификации
class AuthController extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;
  final ApiClient _apiClient;
  final GoogleSignIn _googleSignIn;

  AuthController({
    required IAuthRepository authRepository,
    required ApiClient apiClient,
    GoogleSignIn? googleSignIn,
  })  : _authRepository = authRepository,
        _apiClient = apiClient,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        super(const AuthState());

  /// Вход с помощью Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Инициируем вход через Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Вход через Google отменён',
        );
        return;
      }

      // Получаем аутентификационные данные
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null && idToken == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Не удалось получить токены Google',
        );
        return;
      }

      // Отправляем токены на наш сервер для обмена на наши токены
      final response = await _apiClient.post(
        '/auth/google',
        body: {
          if (accessToken != null) 'access_token': accessToken,
          if (idToken != null) 'id_token': idToken,
        },
      );

      if (response.statusCode == 200) {
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
      // Выход из Google
      await _googleSignIn.signOut();
      // Выход из приложения
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