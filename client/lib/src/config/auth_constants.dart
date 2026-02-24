class AuthConstants {
  static const String googleSignInMethod = 'google.com';
  static const String anonymousSignInMethod = 'anonymous';
  static const String emailPasswordSignInMethod = 'password';

  // Коды ошибок
  static const String errorCodeUserNotFound = 'user-not-found';
  static const String errorCodeWrongPassword = 'wrong-password';
  static const String errorCodeWeakPassword = 'weak-password';
  static const String errorCodeEmailAlreadyInUse = 'email-already-in-use';
  static const String errorCodeInvalidEmail = 'invalid-email';

  // User claims
  static const String userRoleClaim = 'role';
  static const String userPreferencesClaim = 'preferences';
}
