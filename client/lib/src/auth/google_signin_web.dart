// Web-specific Google Sign-In implementation
// Uses signInWithRedirect instead of signInWithPopup to avoid COOP issues

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show debugPrint;

/// Проверяет результат редиректа после Google Sign-In
/// Вызывать один раз при инициализации приложения
Future<UserCredential?> checkGoogleRedirectResult() async {
  if (!kIsWeb) return null;

  try {
    final result = await FirebaseAuth.instance.getRedirectResult();
    if (result != null) {
      debugPrint('✅ Google redirect result: ${result.user?.email}');
      return result;
    }
  } catch (e) {
    debugPrint('❌ Google redirect error: $e');
    // Ошибка редиректа (пользователь отменил или таймаут)
    return null;
  }

  return null;
}

/// Выполняет Google Sign-In используя redirect (для Web)
/// Это обходит проблему Cross-Origin-Opener-Policy
Future<void> signInWithGoogleWeb(GoogleAuthProvider provider) async {
  if (!kIsWeb) return;

  // Начинаем редирект
  // Приложение будет перезапущено после возврата от Google
  await FirebaseAuth.instance.signInWithRedirect(provider);

  // Ждём немного пока Firebase обработает
  await Future.delayed(const Duration(milliseconds: 100));
}
