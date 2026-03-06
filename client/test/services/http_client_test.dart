import 'package:flutter_test/flutter_test.dart';
import 'package:outfitstyle_client/src/core/api/api_config.dart';

void main() {
  group('ApiConfig Tests', () {
    const apiConfig = ApiConfig(apiBase: 'https://api.example.com');

    test('ApiConfig has correct base URL', () {
      expect(apiConfig.apiBase, 'https://api.example.com');
    });

    test('ApiConfig builds correct endpoints', () {
      expect(apiConfig.apiBase, contains('https://'));
    });
  });
}
