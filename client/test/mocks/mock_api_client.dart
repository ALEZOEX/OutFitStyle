import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:dio/dio.dart';

/// Mock для ApiClient
class MockApiClient extends Mock implements ApiClient {}

/// Mock для Dio (используется внутри ApiClient)
class MockDio extends Mock {
  Future<dynamic> get(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return {};
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return {};
  }

  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return {};
  }

  Future<dynamic> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return {};
  }
}

/// Mock для ответов API
class MockApiResponse {
  final int statusCode;
  final dynamic data;

  const MockApiResponse({
    this.statusCode = 200,
    this.data,
  });

  /// Создать успешный ответ
  static MockApiResponse success({dynamic data}) {
    return MockApiResponse(statusCode: 200, data: data);
  }

  /// Создать ответ с ошибкой
  static MockApiResponse error({int statusCode = 400, String message = 'Error'}) {
    return MockApiResponse(
      statusCode: statusCode,
      data: {'error': {'code': statusCode.toString(), 'message': message}},
    );
  }
}

/// Создать мок Response для тестов
Response<T> createMockResponse<T>(T data, {int statusCode = 200}) {
  return Response<T>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: ''),
  );
}

/// Утилиты для мокирования API вызовов
class ApiClientMocks {
  /// Настроить успешный GET запрос
  static void setupGetSuccess({
    required MockApiClient client,
    required String path,
    required dynamic response,
  }) {
    when(() => client.get(path)).thenAnswer((_) async => response);
  }

  /// Настроить GET запрос с ошибкой
  static void setupGetError({
    required MockApiClient client,
    required String path,
    int statusCode = 400,
    String message = 'Error',
  }) {
    when(() => client.get(path)).thenThrow(
      ApiException('Ошибка: $message'),
    );
  }

  /// Настроить успешный POST запрос
  static void setupPostSuccess({
    required MockApiClient client,
    required String path,
    required dynamic response,
  }) {
    when(() => client.post(path)).thenAnswer((_) async => response);
  }

  /// Настроить POST запрос с ошибкой
  static void setupPostError({
    required MockApiClient client,
    required String path,
    int statusCode = 400,
    String message = 'Error',
  }) {
    when(() => client.post(path)).thenThrow(
      ApiException('Ошибка: $message'),
    );
  }

  /// Настроить успешный PUT запрос
  static void setupPutSuccess({
    required MockApiClient client,
    required String path,
    required dynamic response,
  }) {
    when(() => client.put(path)).thenAnswer((_) async => response);
  }

  /// Настроить успешный DELETE запрос
  static void setupDeleteSuccess({
    required MockApiClient client,
    required String path,
  }) {
    when(() => client.delete(path)).thenAnswer((_) async => createMockResponse(<String, dynamic>{}));
  }
}
