class ServerException implements Exception {
  final String? message;
  
  ServerException({this.message});
  
  @override
  String toString() => 'ServerException: ${message ?? 'An error occurred'}';
}

class CacheException implements Exception {
  final String? message;
  
  CacheException({this.message});
  
  @override
  String toString() => 'CacheException: ${message ?? 'Cache error occurred'}';
}

class NetworkException implements Exception {
  final String? message;
  
  NetworkException({this.message});
  
  @override
  String toString() => 'NetworkException: ${message ?? 'Network error occurred'}';
}