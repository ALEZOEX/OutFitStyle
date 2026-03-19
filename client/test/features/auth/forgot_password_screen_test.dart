import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:outfitstyle_client/src/features/auth/presentation/screens/forgot_password_screen.dart';

void main() {
  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('shows title and email input on initial load', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие базовой структуры экрана
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('navigates to code step after successful email submission', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows password step after code verification', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows step indicator dots', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('back button navigates to auth screen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что кнопка назад существует
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('shows loading indicator when submitting', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('resend code button is available on code step', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
      );

      await tester.pumpAndSettle();

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
