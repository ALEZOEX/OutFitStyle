import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/core/services/auth_storage.dart' as core;
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/data/repositories/auth_repository.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart' as impl;
import 'package:outfitstyle_client/src/core/api/api_config.dart';

/// Глобальный провайдер для AuthStorage (единый экземпляр для всего приложения)
final authStorageProvider = Provider<core.AuthStorage>((ref) {
  return impl.AuthStorage();
});

/// Глобальный провайдер для ApiClient (использует единый AuthStorage)
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(authStorageProvider);
  return ApiClient(storage: storage);
});

/// Провайдер для AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authStorage = ref.watch(authStorageProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(
    ApiConfig(apiBase: ApiConfig.baseUrl),
    authStorage,
    apiClient,
  );
});

/// Провайдер для получения userId пользователя
final userIdProvider = FutureProvider<String?>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  return authRepo.getUserId();
});

/// Провайдер состояния авторизации
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.read(authRepositoryProvider));
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AuthState.loading());

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      state = isLoggedIn ? const AuthState.authenticated() : const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signOut() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState._({required this.isLoading, required this.isAuthenticated});
  const AuthState.loading() : this._(isLoading: true, isAuthenticated: false);
  const AuthState.authenticated() : this._(isLoading: false, isAuthenticated: true);
  const AuthState.unauthenticated() : this._(isLoading: false, isAuthenticated: false);
}

/// Провайдер для проверки прав администратора
final adminAccessProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final user = await authRepo.getCurrentUser();
  return user?['role'] == 'admin';
});
