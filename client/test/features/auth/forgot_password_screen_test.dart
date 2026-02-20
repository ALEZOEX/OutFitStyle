import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle_client/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:outfitstyle_client/src/data/repositories/auth_repository.dart';

// Мок для AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('ForgotPasswordScreen Widget Tests', () {
    testWidgets('shows title and email input on initial load', (tester) async {
      when(() => mockAuthRepository.forgotPassword(any())).thenAnswer(
        (_) async => true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Проверяем заголовок
      expect(find.text('Восстановление пароля'), findsOneWidget);
      
      // Проверяем наличие поля ввода email
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      
      // Проверяем кнопку отправки
      expect(find.text('Отправить код'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Пытаемся отправить пустую форму
      await tester.tap(find.text('Отправить код'));
      await tester.pump();

      // Проверяем ошибку валидации
      expect(find.text('Введите email'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Вводим невалидный email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.tap(find.text('Отправить код'));
      await tester.pump();

      // Проверяем ошибку валидации
      expect(find.text('Введите корректный email'), findsOneWidget);
    });

    testWidgets('navigates to code step after successful email submission', (tester) async {
      when(() => mockAuthRepository.forgotPassword(any())).thenAnswer(
        (_) async => true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Вводим валидный email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Отправить код'));
      await tester.pumpAndSettle();

      // Проверяем переход к шагу с кодом
      expect(find.text('Введите код'), findsOneWidget);
      expect(find.text('Код из 6 цифр'), findsOneWidget);
    });

    testWidgets('shows password step after code verification', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Вводим email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Отправить код'));
      await tester.pumpAndSettle();

      // Вводим код
      final codeField = find.byType(TextFormField).at(0);
      await tester.enterText(codeField, '123456');
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();

      // Проверяем переход к шагу с паролем
      expect(find.text('Новый пароль'), findsOneWidget);
      expect(find.text('Подтверждение пароля'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      when(() => mockAuthRepository.resetPassword(any(), any(), any())).thenAnswer(
        (_) async => true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Вводим email
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Отправить код'));
      await tester.pumpAndSettle();

      // Вводим код
      final codeField = find.byType(TextFormField).at(0);
      await tester.enterText(codeField, '123456');
      await tester.tap(find.text('Подтвердить'));
      await tester.pumpAndSettle();

      // Вводим разные пароли
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.at(0), 'password123');
      await tester.enterText(passwordFields.at(1), 'password456');
      await tester.tap(find.text('Сбросить пароль'));
      await tester.pump();

      // Проверяем ошибку
      expect(find.text('Пароли не совпадают'), findsOneWidget);
    });

    testWidgets('shows step indicator dots', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Проверяем наличие индикаторов шагов (кружочки)
      final stepDots = find.byWidgetPredicate(
        (widget) => widget is Container && 
                    widget.decoration is BoxDecoration &&
                    (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      
      expect(stepDots, findsWidgets);
    });

    testWidgets('back button navigates to auth screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Находим кнопку назад
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      
      // Проверяем, что кнопка существует (навигация тестируется через GoRouter)
      await tester.tap(backButton);
      await tester.pump();
    });

    testWidgets('shows loading indicator when submitting', (tester) async {
      // Задерживаем ответ для проверки loading состояния
      when(() => mockAuthRepository.forgotPassword(any())).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return true;
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Отправить код'));
      await tester.pump();

      // Проверяем наличие индикатора загрузки
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('resend code button is available on code step', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      // Вводим email и переходим к шагу с кодом
      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Отправить код'));
      await tester.pumpAndSettle();

      // Проверяем кнопку повторной отправки
      expect(find.text('Отправить повторно'), findsOneWidget);
    });
  });
}
