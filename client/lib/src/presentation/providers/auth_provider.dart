import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart' as impl;
import 'session_provider.dart';

// ============================================================================
// FIREBASE AUTH ПРОВАЙДЕРЫ (основные)
// ============================================================================

/// Провайдер для получения userId пользователя через SessionManager
final userIdProvider = Provider<String?>((ref) {
  return ref.watch(sessionManagerProvider).value?.currentUserId;
});

/// Провайдер состояния авторизации (StreamProvider\<bool\>)
final authStateProvider = StreamProvider<bool>((ref) {
  final sessionManagerAsync = ref.watch(sessionManagerProvider);

  return sessionManagerAsync.whenData(
    (sessionManager) => sessionManager.authStateChanges,
  ).value ??
      Stream.value(false);
});

/// Провайдер для проверки прав администратора
final adminAccessProvider = FutureProvider<bool>((ref) async {
  return false;
});

// ============================================================================
// ПРОВАЙДЕРЫ СОВМЕСТИМОСТИ (для постепенной миграции)
// ============================================================================

/// Провайдер для AuthStorage (заглушка для обратной совместимости)
/// @Deprecated Используйте SessionManager
final authStorageProvider = Provider<impl.AuthStorage>((ref) {
  // Используем async/await для получения SharedPreferences
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => impl.AuthStorage(prefs),
    loading: () => throw StateError('SharedPreferences не инициализированы'),
    error: (e, _) => throw StateError('Ошибка инициализации SharedPreferences: $e'),
  );
});

/// Провайдер для ApiClient (заглушка для обратной совместимости)
/// @Deprecated Используйте SessionManager
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(authStorageProvider);
  return ApiClient(storage: storage);
});

/// Класс состояния авторизации (для обратной совместимости)
/// @Deprecated Используйте authStateProvider напрямую
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState._({required this.isLoading, required this.isAuthenticated});
  const AuthState.loading() : this._(isLoading: true, isAuthenticated: false);
  const AuthState.authenticated() : this._(isLoading: false, isAuthenticated: true);
  const AuthState.unauthenticated() : this._(isLoading: false, isAuthenticated: false);
}

/// Вспомогательный провайдер для router.dart (обратная совместимость)
/// @Deprecated Будет удалён после рефакторинга router.dart
final authStateCompatProvider = Provider<AuthState>((ref) {
  final authStateAsync = ref.watch(authStateProvider);

  return authStateAsync.when(
    data: (isAuthenticated) => isAuthenticated
        ? const AuthState.authenticated()
        : const AuthState.unauthenticated(),
    loading: () => const AuthState.loading(),
    error: (_, __) => const AuthState.unauthenticated(),
  );
});
