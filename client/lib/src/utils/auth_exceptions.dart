/// Custom exception for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;
  final String? details;

  AuthException({required this.code, required this.message, this.details});

  @override
  String toString() =>
      'AuthException: $code - $message${details != null ? ' ($details)' : ''}';
}

/// Authentication failure types
class AuthFailure {
  static final unknown = AuthException(
    code: 'unknown',
    message: 'Произошла неизвестная ошибка',
  );

  static final invalidCredentials = AuthException(
    code: 'invalid_credentials',
    message: 'Неверные учетные данные',
  );

  static final userNotFound = AuthException(
    code: 'user_not_found',
    message: 'Пользователь не найден',
  );

  static final weakPassword = AuthException(
    code: 'weak_password',
    message: 'Слишком слабый пароль',
  );

  static final emailAlreadyInUse = AuthException(
    code: 'email_already_in_use',
    message: 'Этот адрес электронной почты уже используется',
  );

  static final networkError = AuthException(
    code: 'network_error',
    message: 'Ошибка сети. Проверьте подключение к интернету',
  );

  static final tooManyRequests = AuthException(
    code: 'too_many_requests',
    message: 'Слишком много попыток. Попробуйте позже',
  );

  static final invalidEmail = AuthException(
    code: 'invalid_email',
    message: 'Неверный формат адреса электронной почты',
  );
}
