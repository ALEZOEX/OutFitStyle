import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/session_manager.dart';
import '../../core/api/api_client.dart';

/// Провайдер для асинхронной инициализации SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Провайдер FirebaseAuth (единый экземпляр)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Провайдер SessionManager (единый экземпляр для всего приложения)
///
/// SessionManager управляет сессией пользователя через Firebase Auth
/// и сохраняет состояние в SharedPreferences
///
/// Пример использования:
/// ```dart
/// final sessionManager = ref.read(sessionManagerProvider);
/// ```
final sessionManagerProvider = Provider<SessionManager>((ref) {
  // Получаем SharedPreferences асинхронно через FutureProvider
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final apiClient = ref.watch(apiClientProvider);

  return prefsAsync.when(
    data: (prefs) {
      final manager = SessionManager(FirebaseAuth.instance, prefs, apiClient: apiClient);
      // ✅ Правильная очистка при уничтожении провайдера
      ref.onDispose(() => manager.dispose());
      return manager;
    },
    loading: () {
      // Возвращаем временный SessionManager (не используется)
      throw StateError('SharedPreferences не инициализированы');
    },
    error: (e, st) {
      throw StateError('Ошибка инициализации SharedPreferences: $e');
    },
  );
});

/// Провайдер ApiClient с Firebase ID Token авторизацией
///
/// ApiClient автоматически получает свежий Firebase ID Token перед каждым запросом
/// через getIdToken(true), что гарантирует актуальность токена
final apiClientProvider = Provider<ApiClient>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final firebaseAuth = ref.watch(firebaseAuthProvider);

  return prefsAsync.when(
    data: (prefs) => ApiClient(sharedPreferences: prefs, firebaseAuth: firebaseAuth),
    loading: () => throw StateError('SharedPreferences не инициализированы'),
    error: (e, st) => throw StateError('Ошибка инициализации SharedPreferences: $e'),
  );
});

/// Провайдер состояния авторизации (StreamProvider\<bool\>)
///
/// Возвращает поток изменений состояния аутентификации
///
/// Пример использования:
/// ```dart
/// ref.watch(authStateProvider).when(
///   data: (isLoggedIn) => isLoggedIn ? HomeScreen() : LoginScreen(),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error),
/// );
/// ```
final authStateProvider = StreamProvider<bool>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);
  return sessionManager.authStateChanges;
});
