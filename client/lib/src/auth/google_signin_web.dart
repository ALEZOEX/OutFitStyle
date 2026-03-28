// Web-specific Google Sign-In implementation
// Uses signInWithPopup instead of redirect for better UX
// Requires Firebase Console configuration (Authorized domains)

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
