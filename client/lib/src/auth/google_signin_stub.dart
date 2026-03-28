// Stub для не-web платформ
// Использует стандартный signInWithPopup

import 'package:firebase_auth/firebase_auth.dart';

/// Выполняет Google Sign-In используя popup (для Mobile/Desktop)
Future<UserCredential?> signInWithGoogleWeb(GoogleAuthProvider provider) async {
  // На не-web платформах возвращаем null — будет использован стандартный flow
  return null;
}
