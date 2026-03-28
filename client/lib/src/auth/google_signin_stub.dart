// Stub для не-web платформ
// Использует стандартный signInWithPopup

import 'package:firebase_auth/firebase_auth.dart';

/// Проверяет результат редиректа после Google Sign-In (stub для не-web)
Future<UserCredential?> checkGoogleRedirectResult() async {
  return null;
}

/// Выполняет Google Sign-In используя popup (для Mobile/Desktop)
Future<void> signInWithGoogleWeb(GoogleAuthProvider provider) async {
  // На не-web платформах ничего не делаем — будет использован стандартный flow
}
