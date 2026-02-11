// lib/src/core/error/failure.dart

class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  // Фабричные конструкторы которые используются в коде
  factory Failure.serverFailure(String message, {int? statusCode}) {
    return ServerFailure(message, statusCode);
  }

  factory Failure.networkFailure(String message) {
    return NetworkFailure(message);
  }

  factory Failure.cacheFailure(String message) {
    return CacheFailure(message);
  }

  @override
  String toString() => 'Failure($message)';
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error', int? statusCode])
      : super(message, statusCode: statusCode);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
