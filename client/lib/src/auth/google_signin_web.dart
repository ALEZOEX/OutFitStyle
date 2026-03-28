// Web-specific Google Sign-In implementation
// Uses signInWithRedirect instead of signInWithPopup to avoid COOP issues

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Выполняет Google Sign-In используя redirect (для Web)
/// Это обходит проблему Cross-Origin-Opener-Policy
/// 
/// Возвращает UserCredential если это результат редиректа, иначе null
Future<UserCredential?> signInWithGoogleWeb(GoogleAuthProvider provider) async {
  if (!kIsWeb) return null;
  
  try {
    // Проверяем, есть ли уже результат редиректа
    final result = await FirebaseAuth.instance.getRedirectResult();
    if (result != null) {
      return result;
    }
  } catch (e) {
    // Ошибка редиректа (пользователь отменил или таймаут)
    return null;
  }
  
  // Если нет результата, начинаем редирект
  // Приложение будет перезапущено после возврата от Google
  await FirebaseAuth.instance.signInWithRedirect(provider);
  
  // Ждём немного пока Firebase обработает
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Возвращаем null — приложение будет перезапущено после редиректа
  return null;
}
