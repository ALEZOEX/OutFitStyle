class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class ApiServiceException extends ApiException {
  final int statusCode;
  final String endpoint;

  const ApiServiceException(
      super.message,
      this.statusCode,
      this.endpoint,
      );

  @override
  String toString() =>
      'Ошибка API: $message (Статус: $statusCode, Эндпоинт: $endpoint)';
}

/// Сессия недействительна (пользователь не найден / токен протух)
class AuthExpiredException extends ApiException {
  const AuthExpiredException(String message) : super(message);
}