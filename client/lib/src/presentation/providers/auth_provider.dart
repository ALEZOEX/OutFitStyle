import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart' as impl;
import 'session_provider.dart' show sessionManagerProvider, authStateProvider, apiClientProvider;

// ============================================================================
// FIREBASE AUTH ПРОВАЙДЕРЫ (основные)
// ============================================================================

/// Провайдер для получения userId пользователя через SessionManager
final userIdProvider = Provider<String?>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return sessionManager.currentUserId;
});

// Экспортируем authStateProvider из session_provider.dart
// final authStateProvider = StreamProvider<bool>((ref) { ... });

/// Провайдер для проверки прав администратора
final adminAccessProvider = FutureProvider<bool>((ref) async {
  return false;
});

// ============================================================================
// ПРОВАЙДЕРЫ СОВМЕСТИМОСТИ (для постепенной миграции)
// ============================================================================

/// Провайдер для AuthStorage (Market Service API)
/// @Deprecated Используйте SessionManager для пользовательской аутентификации
@Deprecated('Используйте SessionManager для аутентификации. JWT auth устарел.')
final authStorageProvider = Provider<impl.AuthStorage>((ref) {
  // Используется только для обратной совместимости
  throw StateError('authStorageProvider больше не используется. Используйте SessionManager.');
});

/// Класс состояния авторизации (для обратной совместимости)
/// @Deprecated Используйте authStateProvider напрямую [StreamProvider]
@Deprecated('Используйте authStateProvider напрямую. Будет удалён после миграции router.dart.')
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;

  const AuthState._({required this.isLoading, required this.isAuthenticated});
  const AuthState.loading() : this._(isLoading: true, isAuthenticated: false);
  const AuthState.authenticated() : this._(isLoading: false, isAuthenticated: true);
  const AuthState.unauthenticated() : this._(isLoading: false, isAuthenticated: false);
}

/// Вспомогательный провайдер для router.dart (обратная совместимость)
/// @Deprecated Будет удалён после миграции router.dart на authStateProvider
@Deprecated('Используйте authStateProvider напрямую. Будет удалён после миграции router.dart.')
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
