// Web-specific Google Sign-In implementation
// Uses signInWithPopup instead of redirect for better UX
// Requires Firebase Console configuration (Authorized domains)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show debugPrint;

/// Проверяет результат редиректа после Google Sign-In
/// Вызывать один раз при инициализации приложения
/// Повторяет попытку несколько раз с задержкой
Future<UserCredential?> checkGoogleRedirectResult() async {
  if (!kIsWeb) return null;

  // Пробуем несколько раз с задержкой (Firebase может быть не готов сразу)
  for (int attempt = 1; attempt <= 5; attempt++) {
    try {
      debugPrint('🔄 Google redirect check attempt $attempt/5...');
      
      final result = await FirebaseAuth.instance.getRedirectResult();
      if (result != null) {
        debugPrint('✅ Google redirect result: ${result.user?.email}');
        return result;
      }
      
      // Если результат null, ждём и пробуем снова
      if (attempt < 5) {
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    } catch (e) {
      debugPrint('❌ Google redirect error (attempt $attempt): $e');
      // Ошибка редиректа (пользователь отменил или таймаут)
      return null;
    }
  }

  debugPrint('⚠️ Google redirect result: null (after 5 attempts)');
  return null;
}

/// Выполняет Google Sign-In используя popup (для Web)
/// Требует настройки Firebase Console (Authorized domains)
Future<UserCredential?> signInWithGoogleWeb(GoogleAuthProvider provider) async {
  if (!kIsWeb) return null;

  try {
    // Пробуем signInWithPopup
    final result = await FirebaseAuth.instance.signInWithPopup(provider);
    debugPrint('✅ Google popup sign-in success: ${result.user?.email}');
    return result;
  } catch (e) {
    debugPrint('❌ Google popup sign-in error: $e');
    // Если popup заблокирован, пробуем redirect
    await FirebaseAuth.instance.signInWithRedirect(provider);
    await Future.delayed(const Duration(milliseconds: 100));
    return null;
  }
}
