import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/session_manager.dart';

/// Провайдер для асинхронной инициализации SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Провайдер SessionManager (единый экземпляр для всего приложения)
///
/// SessionManager управляет сессией пользователя через Firebase Auth
/// и сохраняет состояние в SharedPreferences
///
/// Пример использования:
/// ```dart
/// // Через async/await:
/// final sessionManager = await ref.read(sessionManagerProvider.future);
/// ```
final sessionManagerProvider = FutureProvider<SessionManager>((ref) async {
  final firebaseAuth = FirebaseAuth.instance;
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);

  return SessionManager(firebaseAuth, sharedPreferences);
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
  // Создаём контроллер для трансляции authStateChanges
  final controller = StreamController<bool>.broadcast();
  
  // Подписываемся на SessionManager асинхронно
  ref.watch(sessionManagerProvider.future).then((sessionManager) {
    final subscription = sessionManager.authStateChanges.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    
    // Отменяем подписку при уничтожении провайдера
    ref.onDispose(() => subscription.cancel());
  }).catchError((error) {
    controller.addError(error);
    controller.close();
  });
  
  return controller.stream;
});
