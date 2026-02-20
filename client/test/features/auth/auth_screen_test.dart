import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outfitstyle_client/src/features/auth/presentation/auth_screen.dart';
import 'package:outfitstyle_client/src/features/auth/presentation/screens/forgot_password_screen.dart';

// Mocks
class MockAuthListener extends Mock {}

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

      // Проверяем наличие полей ввода
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Войти'), findsOneWidget);
      expect(find.text('Зарегистрироваться'), findsOneWidget);
    });

    testWidgets('AuthScreen toggle between login and register', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Изначально показана форма входа
      expect(find.text('Войти'), findsOneWidget);
      expect(find.text('Зарегистрироваться'), findsOneWidget);

      // Переключаемся на регистрацию
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pumpAndSettle();

      // Проверяем, что форма изменилась
      expect(find.text('Создать аккаунт'), findsOneWidget);
    });

    testWidgets('AuthScreen validates empty email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Пытаемся отправить пустую форму
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Должна быть ошибка валидации
      expect(find.textContaining('email'), findsWidgets);
    });

    testWidgets('AuthScreen validates empty password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Вводим email, но не пароль
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.pump();

      // Пытаемся отправить
      await tester.tap(find.text('Войти'));
      await tester.pump();

      // Должна быть ошибка валидации пароля
      expect(find.textContaining('пароль'), findsWidgets);
    });

    testWidgets('AuthScreen accepts valid input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Вводим валидные данные
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Password123!',
      );
      await tester.pump();

      // Форма должна принять данные (нет ошибок валидации)
      expect(find.text('test@example.com'), findsOneWidget);
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

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Восстановить пароль'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen validates email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Вводим неверный email
      await tester.enterText(
        find.byType(TextFormField),
        'invalid-email',
      );
      await tester.pump();

      await tester.tap(find.text('Восстановить пароль'));
      await tester.pump();

      // Должна быть ошибка валидации
      expect(find.textContaining('email'), findsWidgets);
    });
  });
}
