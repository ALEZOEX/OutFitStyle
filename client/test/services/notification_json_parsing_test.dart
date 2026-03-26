import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';

class MockApiClient implements ApiClient {
  final Dio _dio = Dio();
  String? mockResponseData;
  int mockStatusCode = 200;
  String? mockErrorMessage;
  bool shouldThrowError = false;

  @override
  Dio get raw => _dio;

  @override
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    if (shouldThrowError) {
      throw ApiException(mockErrorMessage ?? 'Unknown error');
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: mockStatusCode,
      data: mockResponseData,
    );
  }

  @override
  Future<Response> post(String path, {dynamic data}) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {},
    );
  }

  @override
  Future<Response> put(String path, {dynamic data}) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {},
    );
  }

  @override
  Future<Response> delete(String path) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {},
    );
  }
}

void main() {
  group('NotificationRemoteDataSource', () {
    late MockApiClient mockApiClient;
    late NotificationRemoteDataSource dataSource;

    setUp(() {
      mockApiClient = MockApiClient();
      dataSource = NotificationRemoteDataSource(mockApiClient);
    });

    test('getNotifications throws FormatException when response is HTML not JSON', () async {
      // Simulate HTML error page response (like from nginx 401 page)
      mockApiClient.mockResponseData = '''
<!DOCTYPE html>
<html>
<head><title>401 Authorization Required</title></head>
<body><h1>401 Authorization Required</h1></body>
</html>
''';
      mockApiClient.mockStatusCode = 401;

      expect(
        () => dataSource.getNotifications(),
        throwsA(isA<FormatException>()),
      );
    });

    test('getNotifications parses valid JSON correctly', () async {
      mockApiClient.mockResponseData = '''
{
  "notifications": [
    {
      "id": "test-1",
      "user_id": "user-123",
      "type": "info",
      "title": "Test Notification",
      "body": "Test body",
      "created_at": "2026-03-26T12:00:00Z",
      "is_read": false
    }
  ],
  "unread_count": 1,
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1
  }
}
''';
      mockApiClient.mockStatusCode = 200;

      final result = await dataSource.getNotifications();
      expect(result.notifications.length, 1);
      expect(result.unreadCount, 1);
    });

    test('getUnreadCount throws when API returns non-JSON', () async {
      mockApiClient.mockResponseData = 'Internal Server Error';
      mockApiClient.mockStatusCode = 500;

      expect(
        () => dataSource.getUnreadCount(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}