class ApiException implements Exception {
  final String message;
  final String? errorMessage;
  
  const ApiException(this.message, [this.errorMessage]);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(String message) : super(message);
}

class ApiServiceException extends ApiException {
  final int statusCode;
  final String endpoint;

  const ApiServiceException(
    String message,
    this.statusCode,
    this.endpoint,
  ) : super(message);
}

/// Сессия недействительна (пользователь не найден / токен протух)
class AuthExpiredException extends ApiException {
  const AuthExpiredException(String message) : super(message);
}