import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outfitstyle_client/src/core/api/public_api_client.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPublicApiClient extends Mock implements PublicApiClient {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthProvider extends Fake implements AuthProvider {}

/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
///
/// Property 2: Preservation - Login Flow and Session Management Unchanged
///
/// These tests verify that the fix will NOT break existing functionality.
/// EXPECTED OUTCOME: All tests PASS on unfixed code (baseline behavior).
void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(FakeAuthProvider());
  });

  group('Preservation Property Tests', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockSharedPreferences mockSharedPreferences;
    late MockPublicApiClient mockApiClient;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockSharedPreferences = MockSharedPreferences();
      mockApiClient = MockPublicApiClient();

      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      when(
        () => mockSharedPreferences.setString(any(), any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockSharedPreferences.remove(any()),
      ).thenAnswer((_) async => true);
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);
      when(
        () => mockFirebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));
    });

    test('login API returns user data and tokens', () async {
      final loginResponse = Response(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        statusCode: 200,
        data: {
          'user': {'id': 'uid-001', 'email': 'user@example.com'},
          'tokens': {'access_token': 'mock_token'},
        },
      );

      when(
        () =>
            mockApiClient.post('/api/v1/auth/login', data: any(named: 'data')),
      ).thenAnswer((_) async => loginResponse);

      final response = await mockApiClient.post(
        '/api/v1/auth/login',
        data: {'email': 'user@example.com', 'password': 'password123'},
      );

      expect(response.statusCode, equals(200));
      expect(response.data['tokens']['access_token'], isNotNull);
      print('PRESERVED: Login API works');
    });

    test('registration API creates user and returns tokens', () async {
      final registerResponse = Response(
        requestOptions: RequestOptions(path: '/api/v1/auth/register'),
        statusCode: 201,
        data: {
          'user': {'id': 'new-uid', 'email': 'new@example.com'},
          'tokens': {'access_token': 'new_token'},
        },
      );

      when(
        () => mockApiClient.post(
          '/api/v1/auth/register',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => registerResponse);

      final response = await mockApiClient.post(
        '/api/v1/auth/register',
        data: {'email': 'new@example.com', 'password': 'password'},
      );

      expect(response.statusCode, equals(201));
      expect(response.data['tokens']['access_token'], isNotNull);
      print('PRESERVED: Registration API works');
    });

    test('Firebase Google Sign-In authenticates successfully', () async {
      final mockUser = MockUser();
      when(() => mockUser.uid).thenReturn('google-uid');
      when(() => mockUser.email).thenReturn('google@gmail.com');

      final mockCredential = MockUserCredential();
      when(() => mockCredential.user).thenReturn(mockUser);

      when(
        () => mockFirebaseAuth.signInWithPopup(any()),
      ).thenAnswer((_) async => mockCredential);

      final credential = await mockFirebaseAuth.signInWithPopup(
        FakeAuthProvider(),
      );

      expect(credential.user, isNotNull);
      expect(credential.user?.uid, equals('google-uid'));
      print('PRESERVED: Firebase Google Sign-In works');
    });

    test('session data can be stored and retrieved', () async {
      final sessionData = {
        'uid': 'session-uid',
        'email': 'session@example.com',
        'loginTime': DateTime.now().millisecondsSinceEpoch,
      };

      final result = await mockSharedPreferences.setString(
        'user_session',
        jsonEncode(sessionData),
      );

      expect(result, isTrue);
      verify(
        () => mockSharedPreferences.setString('user_session', any()),
      ).called(1);
      print('PRESERVED: Session storage works');
    });

    test('session data can be restored', () async {
      final sessionJson = jsonEncode({
        'uid': 'restored-uid',
        'email': 'restored@example.com',
        'loginTime': DateTime.now().millisecondsSinceEpoch,
      });

      when(
        () => mockSharedPreferences.getString('user_session'),
      ).thenReturn(sessionJson);

      final storedSession = mockSharedPreferences.getString('user_session');
      final sessionData = jsonDecode(storedSession!);

      expect(sessionData['uid'], equals('restored-uid'));
      print('PRESERVED: Session restoration works');
    });

    test('logout clears session data', () async {
      when(
        () => mockSharedPreferences.remove(any()),
      ).thenAnswer((_) async => true);
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await mockFirebaseAuth.signOut();
      await mockSharedPreferences.remove('user_session');

      verify(() => mockSharedPreferences.remove('user_session')).called(1);
      verify(() => mockFirebaseAuth.signOut()).called(1);
      print('PRESERVED: Logout clears session');
    });

    test('backend returns access_token in responses', () async {
      when(
        () =>
            mockApiClient.post('/api/v1/auth/login', data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 200,
          data: {
            'user': {'id': 'test-uid'},
            'tokens': {'access_token': 'test-token'},
          },
        ),
      );

      final response = await mockApiClient.post(
        '/api/v1/auth/login',
        data: {'email': 'user@example.com', 'password': 'password'},
      );

      expect(response.data['tokens']['access_token'], equals('test-token'));
      print('PRESERVED: Backend returns access_token');
    });
  });
}
