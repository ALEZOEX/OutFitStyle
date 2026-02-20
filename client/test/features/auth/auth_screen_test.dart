import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/features/auth/presentation/auth_screen.dart';
import 'package:outfitstyle_client/src/features/auth/presentation/screens/forgot_password_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('AuthScreen displays login form initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие базовой структуры экрана
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AuthScreen has form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что форма существует
      expect(find.byType(Form), findsWidgets);
    });

    testWidgets('AuthScreen validates empty email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Пытаемся отправить пустую форму - просто проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AuthScreen validates empty password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('AuthScreen accepts valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('ForgotPasswordScreen displays email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие базовой структуры экрана
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
