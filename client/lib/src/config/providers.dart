import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

final dioProvider = Provider((ref) => Dio(BaseOptions(
      baseUrl: '', // относительные запросы на /api/v1/* (nginx проксирует)
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ))
      ..interceptors.add(LoggingInterceptor()));

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info('API Request: ${options.method} ${options.path}');
    AppLogger.debug('Request Headers: ${options.headers}');
    AppLogger.debug('Request Data: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
        'API Response: ${response.statusCode} ${response.requestOptions.path}');
    AppLogger.debug('Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('API Error: ${err.type} ${err.requestOptions.path}',
        err.message, err.stackTrace);
    super.onError(err, handler);
  }
}
