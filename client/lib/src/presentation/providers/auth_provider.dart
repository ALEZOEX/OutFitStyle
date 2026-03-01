import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_config.dart';
import '../../services/auth_storage.dart';

/// Провайдер для AuthStorage (единый экземпляр для всего приложения)
final authStorageProvider = Provider<AuthStorage>((ref) {
  return AuthStorage();
});

/// Провайдер для ApiClient (использует единый AuthStorage)
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(authStorageProvider);
  return ApiClient(storage: storage);
});

/// Провайдер для AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authStorage = ref.watch(authStorageProvider);
  final apiClient = ref.watch(apiClientProvider);
  final config = ApiConfig(apiBase: ApiConfig.baseUrl);
  return AuthRepository(config, authStorage, apiClient);
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

/// Состояние авторизации
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState._({required this.isLoading, required this.isAuthenticated});
  const AuthState.loading() : this._(isLoading: true, isAuthenticated: false);
  const AuthState.authenticated() : this._(isLoading: false, isAuthenticated: true);
  const AuthState.unauthenticated() : this._(isLoading: false, isAuthenticated: false);
}

/// Нотификатор состояния авторизации
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(const AuthState.loading());

  /// Проверить состояние авторизации
  Future<void> checkAuth() async {
    state = const AuthState.loading();
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      state = isLoggedIn ? const AuthState.authenticated() : const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Выйти из системы
  Future<void> signOut() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}

/// Провайдер для проверки прав администратора
final adminAccessProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  try {
    final token = await authRepo.authStorage.readAccessToken();
    if (token == null) return false;

    // Получаем роль из JWT claims (payload)
    // JWT формат: header.payload.signature
    final parts = token.split('.');
    if (parts.length != 3) return false;

    // Декодируем payload (base64url)
    String payload = parts[1];
    // Добавляем padding если нужно
    final padding = 4 - payload.length % 4;
    if (padding != 4) {
      payload += '=' * padding;
    }

    // Заменяем URL-safe символы
    payload = payload.replaceAll('-', '+').replaceAll('_', '/');

    final decoded = utf8.decode(base64.decode(payload));
    final json = jsonDecode(decoded) as Map<String, dynamic>;

    // Проверяем роль
    final role = json['role'] as String?;
    return role == 'admin';
  } catch (e) {
    return false;
  }
});
