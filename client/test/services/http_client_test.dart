import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outfitstyle_client/src/services/http_client.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';

// Mock для AuthStorage
class MockAuthStorage extends Mock implements AuthStorage {}

void main() {
  group('AuthenticatedHttpClient Tests', () {
    late ApiConfig apiConfig;
    late AuthStorage authStorage;

    setUp(() {
      apiConfig = const ApiConfig(apiBase: 'https://api.example.com');
      authStorage = MockAuthStorage();
    });

    testWidgets('adds auth header when token exists', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(request.headers['Content-Type'], 'application/json');
        return http.Response('{"success": true}', 200);
      });

      when(() => authStorage.readAccessToken()).thenAnswer((_) async => 'test-token');

      final client = AuthenticatedHttpClient(mockClient, apiConfig, authStorage);

      final response = await client.get(Uri.parse('https://api.example.com/test'));
      expect(response.statusCode, 200);
    });

    testWidgets('works without auth token', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], isNull);
        expect(request.headers['Content-Type'], 'application/json');
        return http.Response('{"success": true}', 200);
      });

      when(() => authStorage.readAccessToken()).thenAnswer((_) async => null);

      final client = AuthenticatedHttpClient(mockClient, apiConfig, authStorage);

      final response = await client.get(Uri.parse('https://api.example.com/test'));
      expect(response.statusCode, 200);
    });

    testWidgets('handles 401 response', (WidgetTester tester) async {
      var refreshCalled = false;

      final mockClient = MockClient((request) async {
        if (request.url.path == '/auth/refresh') {
          refreshCalled = true;
          return http.Response('{"access_token": "new-token"}', 200);
        }
        return http.Response('Unauthorized', 401);
      });

      when(() => authStorage.readAccessToken()).thenAnswer((_) async => 'expired-token');
      when(() => authStorage.readRefreshToken()).thenAnswer((_) async => 'refresh-token');

      final client = AuthenticatedHttpClient(mockClient, apiConfig, authStorage);

      final response = await client.get(Uri.parse('https://api.example.com/test'));
      
      // Первый запрос вернет 401, затем будет попытка refresh
      expect(response.statusCode, 401);
      expect(refreshCalled, true);
    });

    testWidgets('adds content-type header', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Content-Type'], 'application/json');
        return http.Response('{"success": true}', 200);
      });

      when(() => authStorage.readAccessToken()).thenAnswer((_) async => null);

      final client = AuthenticatedHttpClient(mockClient, apiConfig, authStorage);

      final response = await client.post(
        Uri.parse('https://api.example.com/test'),
        body: jsonEncode({'key': 'value'}),
      );
      expect(response.statusCode, 200);
    });
  });

  group('ApiConfig Tests', () {
    test('ApiConfig has correct base URL', () {
      const config = ApiConfig(apiBase: 'https://api.example.com');
      expect(config.apiBase, 'https://api.example.com');
    });

    test('ApiConfig builds correct endpoints', () {
      const config = ApiConfig(apiBase: 'https://api.example.com');
      expect(config.apiBase, contains('https://'));
    });
  });
}
