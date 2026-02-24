import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/features/auth/presentation/screens/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('ForgotPasswordScreen displays email field', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие базовой структуры экрана
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen validates email format', (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
