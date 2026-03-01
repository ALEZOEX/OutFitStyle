import 'package:flutter_test/flutter_test.dart';
import 'package:outfitstyle_client/src/presentation/providers/auth_provider.dart';

void main() {
  group('Auth Provider Tests', () {
    test('authStateProvider is defined', () {
      expect(authStateProvider, isNotNull);
    });

    test('userIdProvider is defined', () {
      expect(userIdProvider, isNotNull);
    });

    test('adminAccessProvider is defined', () {
      expect(adminAccessProvider, isNotNull);
    });
  });
}
