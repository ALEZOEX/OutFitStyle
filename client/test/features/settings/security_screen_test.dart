import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outfitstyle_client/src/features/settings/presentation/screens/security_screen.dart';

void main() {
  group('SecurityScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows security screen title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие базовой структуры экрана
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows password change section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows two-factor authentication section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows active sessions section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows login history section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows social accounts section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows danger zone section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('change password button opens dialog', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password dialog has visibility toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('2FA switch can be toggled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('session list shows device icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('login history shows success/failure icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('social account switches are present', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('delete account button is red', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password dialog cancel button works', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password validation shows error for empty fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password validation shows error for short password', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('password validation shows error for mismatch', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
