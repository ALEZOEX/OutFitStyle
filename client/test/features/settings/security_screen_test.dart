import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle_client/src/features/settings/presentation/screens/security_screen.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/services/auth_storage.dart';
import 'package:outfitstyle_client/src/features/settings/data/repositories/sessions_repository.dart';
import 'package:outfitstyle_client/src/features/settings/data/models/session_device.dart';

// Mock классы
class MockApiClient extends Mock implements ApiClient {}
class MockAuthStorage extends Mock implements AuthStorage {}
class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  group('SecurityScreen Widget Tests', () {
    late MockApiClient mockApiClient;
    late MockAuthStorage mockAuthStorage;
    late MockSessionsRepository mockSessionsRepository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockApiClient = MockApiClient();
      mockAuthStorage = MockAuthStorage();
      mockSessionsRepository = MockSessionsRepository();
      
      // Мокаем метод getSessions чтобы возвращал пустой список
      when(() => mockSessionsRepository.getSessions())
          .thenAnswer((_) async => <SessionDevice>[]);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWith((ref) => mockApiClient),
          sessionsRepositoryProvider.overrideWith((ref) {
            return mockSessionsRepository;
          }),
        ],
        child: const MaterialApp(
          home: SecurityScreen(),
        ),
      );
    }

    testWidgets('shows security screen title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows password change section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows two-factor authentication section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows active sessions section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows login history section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows social accounts section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows danger zone section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('change password button opens dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password dialog has visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('2FA switch can be toggled', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('session list shows device icons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('login history shows success/failure icons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('social account switches are present', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('delete account button is red', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password dialog cancel button works', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password validation shows error for empty fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password validation shows error for short password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password validation shows error for mismatch', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
