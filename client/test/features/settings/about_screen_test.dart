import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:outfitstyle_client/src/features/settings/presentation/screens/about_screen.dart';

void main() {
  group('AboutScreen Widget Tests', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'OutfitStyle',
        packageName: 'com.outfitstyle.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    });

    testWidgets('shows about screen title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем заголовок
      expect(find.text('О приложении'), findsOneWidget);
    });

    testWidgets('shows app name', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем название приложения
      expect(find.text('OutfitStyle'), findsOneWidget);
    });

    testWidgets('shows app version', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем версию
      expect(find.textContaining('v1.0.0'), findsOneWidget);
      expect(find.textContaining('build 1'), findsOneWidget);
    });

    testWidgets('shows app icon', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие иконки приложения
      expect(find.byIcon(Icons.style), findsWidgets);
    });

    testWidgets('shows description section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем описание
      expect(find.text('О приложении'), findsWidgets);
      expect(find.textContaining('OutfitStyle'), findsWidgets);
    });

    testWidgets('shows social media section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем секцию соцсетей
      expect(find.text('Мы в соцсетях'), findsOneWidget);
      expect(find.text('Сайт'), findsOneWidget);
      expect(find.text('Telegram'), findsOneWidget);
      expect(find.text('VK'), findsOneWidget);
    });

    testWidgets('shows documents section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем секцию документов
      expect(find.text('Документы'), findsOneWidget);
      expect(find.text('Политика конфиденциальности'), findsOneWidget);
      expect(find.text('Условия использования'), findsOneWidget);
    });

    testWidgets('shows team section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем секцию команды
      expect(find.text('Команда'), findsOneWidget);
      expect(find.text('Показать команду'), findsOneWidget);
    });

    testWidgets('shows licenses section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем секцию лицензий
      expect(find.text('Лицензии'), findsOneWidget);
      expect(find.text('Открыть лицензии'), findsOneWidget);
    });

    testWidgets('team dialog shows team members', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Открываем диалог команды
      await tester.tap(find.text('Показать команду'));
      await tester.pumpAndSettle();

      // Проверяем наличие членов команды
      expect(find.text('Команда разработчиков'), findsOneWidget);
      expect(find.text('Александр Петров'), findsOneWidget);
      expect(find.text('Мария Иванова'), findsOneWidget);
      expect(find.text('Дмитрий Сидоров'), findsOneWidget);
      expect(find.text('Елена Козлова'), findsOneWidget);
      expect(find.text('Алексей Новиков'), findsOneWidget);
    });

    testWidgets('team dialog shows roles', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Показать команду'));
      await tester.pumpAndSettle();

      // Проверяем роли
      expect(find.text('Lead Developer'), findsOneWidget);
      expect(find.text('UI/UX Designer'), findsOneWidget);
      expect(find.text('ML Engineer'), findsOneWidget);
      expect(find.text('Backend Developer'), findsOneWidget);
      expect(find.text('Mobile Developer'), findsOneWidget);
    });

    testWidgets('team dialog can be closed', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Показать команду'));
      await tester.pumpAndSettle();

      // Закрываем диалог
      await tester.tap(find.text('Закрыть'));
      await tester.pumpAndSettle();

      // Проверяем закрытие
      expect(find.text('Команда разработчиков'), findsNothing);
    });

    testWidgets('licenses button opens license page', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Нажимаем кнопку лицензий
      await tester.tap(find.text('Открыть лицензии'));
      await tester.pumpAndSettle();

      // Проверяем открытие страницы лицензий
      expect(find.text('OutfitStyle'), findsWidgets);
    });

    testWidgets('shows gradient logo container', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие контейнера с градиентом
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows info icon in description', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем иконку информации
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows share icon in social section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем иконку分享
      expect(find.byIcon(Icons.share), findsWidgets);
    });

    testWidgets('shows description icon', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем иконку документов
      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('shows groups icon in team section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем иконку команды
      expect(find.byIcon(Icons.groups), findsOneWidget);
    });

    testWidgets('shows account balance icon in licenses', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем иконку лицензий
      expect(find.byIcon(Icons.account_balance), findsOneWidget);
    });

    testWidgets('shows open in new icons for links', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем иконки внешних ссылок
      expect(find.byIcon(Icons.open_in_new), findsWidgets);
    });

    testWidgets('shows feature descriptions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AboutScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем описание функций
      expect(find.textContaining('погоды'), findsOneWidget);
      expect(find.textContaining('предпочтений'), findsOneWidget);
      expect(find.textContaining('трендов'), findsOneWidget);
      expect(find.textContaining('искусственного интеллекта'), findsOneWidget);
    });
  });
}
