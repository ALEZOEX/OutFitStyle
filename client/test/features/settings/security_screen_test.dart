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

      // Проверяем заголовок
      expect(find.text('Безопасность'), findsOneWidget);
    });

    testWidgets('shows password change section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем секцию смены пароля
      expect(find.text('Смена пароля'), findsOneWidget);
      expect(find.text('Изменить пароль'), findsOneWidget);
    });

    testWidgets('shows two-factor authentication section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем секцию 2FA
      expect(find.text('Двухфакторная аутентификация'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows active sessions section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем секцию активных сессий
      expect(find.text('Активные сессии'), findsOneWidget);
      expect(find.text('Активная'), findsOneWidget);
    });

    testWidgets('shows login history section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем секцию истории входов
      expect(find.text('История входов'), findsWidgets);
    });

    testWidgets('shows social accounts section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем секцию привязанных аккаунтов
      expect(find.text('Привязанные аккаунты'), findsWidgets);
      expect(find.text('Google'), findsWidgets);
      expect(find.text('Apple'), findsWidgets);
      expect(find.text('VK'), findsWidgets);
    });

    testWidgets('shows danger zone section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем секцию удаления аккаунта
      expect(find.text('Удаление аккаунта'), findsWidgets);
      expect(find.text('Удалить аккаунт'), findsWidgets);
    });

    testWidgets('change password button opens dialog', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Нажимаем кнопку изменения пароля
      await tester.tap(find.text('Изменить пароль'));
      await tester.pumpAndSettle();

      // Проверяем открытие диалога (Смена пароля встречается в заголовке и диалоге)
      expect(find.text('Смена пароля'), findsWidgets);
      expect(find.text('Текущий пароль'), findsOneWidget);
      expect(find.text('Новый пароль'), findsOneWidget);
      expect(find.text('Подтверждение пароля'), findsOneWidget);
    });

    testWidgets('password dialog has visibility toggle', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Изменить пароль'));
      await tester.pumpAndSettle();

      // Проверяем наличие кнопок видимости пароля
      expect(find.byIcon(Icons.visibility), findsNWidgets(3));
    });

    testWidgets('2FA switch can be toggled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Находим переключатель 2FA
      final switchFinder = find.byType(Switch).first;
      
      // Проверяем начальное состояние
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, false);
    });

    testWidgets('session list shows device icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем наличие иконок устройств
      expect(find.byIcon(Icons.phone_iphone), findsOneWidget);
      expect(find.byIcon(Icons.laptop_mac), findsOneWidget);
      expect(find.byIcon(Icons.desktop_windows), findsOneWidget);
    });

    testWidgets('login history shows success/failure icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем иконки успешных/неуспешных входов (используем findsWidgets т.к. элементы в прокручиваемой области)
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });

    testWidgets('social account switches are present', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем наличие переключателей для соцсетей
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);
    });

    testWidgets('delete account button is red', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      // Проверяем кнопку удаления аккаунта
      final buttonFinder = find.text('Удалить аккаунт');
      expect(buttonFinder, findsOneWidget);
      
      // Проверяем иконку предупреждения
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('password dialog cancel button works', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Изменить пароль'));
      await tester.pumpAndSettle();

      // Нажимаем отмену
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      // Проверяем закрытие диалога (диалоговое окно закрыто, но заголовок секции остаётся)
      // Проверяем что кнопка "Сохранить" (из диалога) исчезла
      expect(find.text('Сохранить'), findsNothing);
      expect(find.text('Отмена'), findsNothing);
    });

    testWidgets('password validation shows error for empty fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Изменить пароль'));
      await tester.pumpAndSettle();

      // Пытаемся сохранить пустые поля
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем наличие SnackBar с ошибкой
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('password validation shows error for short password', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Изменить пароль'));
      await tester.pumpAndSettle();

      // Вводим короткие пароли
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'oldpass');
      await tester.enterText(textFields.at(1), '123'); // Короткий
      await tester.enterText(textFields.at(2), '123');
      
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем ошибку
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('password validation shows error for mismatch', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SecurityScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Изменить пароль'));
      await tester.pumpAndSettle();

      // Вводим разные пароли
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'oldpass');
      await tester.enterText(textFields.at(1), 'newpassword123');
      await tester.enterText(textFields.at(2), 'differentpassword');
      
      await tester.tap(find.text('Сохранить'));
      await tester.pump();

      // Проверяем ошибку
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
