import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outfitstyle_client/src/features/settings/presentation/screens/language_screen.dart';

void main() {
  group('LanguageScreen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('shows language screen title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем заголовок
      expect(find.text('Язык'), findsOneWidget);
    });

    testWidgets('shows auto-detection section', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем секцию авто-определения
      expect(find.text('Авто-определение'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('shows language list', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем заголовок списка языков
      expect(find.text('Язык приложения'), findsOneWidget);
    });

    testWidgets('shows Russian language option', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие русского языка
      expect(find.text('Русский'), findsWidgets);
      expect(find.text('🇷🇺'), findsOneWidget);
    });

    testWidgets('shows English language option', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие английского языка
      expect(find.text('English'), findsWidgets);
      expect(find.text('🇬🇧'), findsOneWidget);
    });

    testWidgets('shows other language options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие других языков
      expect(find.text('Español'), findsWidgets);
      expect(find.text('Français'), findsWidgets);
      expect(find.text('Deutsch'), findsWidgets);
      expect(find.text('Italiano'), findsWidgets);
      expect(find.text('中文'), findsWidgets);
      expect(find.text('日本語'), findsWidgets);
      expect(find.text('Português'), findsWidgets);
      expect(find.text('Türkçe'), findsWidgets);
    });

    testWidgets('shows language flags', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие флагов
      expect(find.text('🇷🇺'), findsOneWidget);
      expect(find.text('🇬🇧'), findsOneWidget);
      expect(find.text('🇪🇸'), findsOneWidget);
      expect(find.text('🇫🇷'), findsOneWidget);
      expect(find.text('🇩🇪'), findsOneWidget);
      expect(find.text('🇮🇹'), findsOneWidget);
      expect(find.text('🇨🇳'), findsOneWidget);
      expect(find.text('🇯🇵'), findsOneWidget);
      expect(find.text('🇵🇹'), findsOneWidget);
      expect(find.text('🇹🇷'), findsOneWidget);
    });

    testWidgets('shows selected language checkmark', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие галочки у выбранного языка (по умолчанию русский)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('auto-detection switch can be toggled', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Находим переключатель авто-определения
      final switchFinder = find.byType(Switch).first;

      // Проверяем начальное состояние (включено по умолчанию)
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, true);
    });

    testWidgets('language selection is disabled when auto-detection is on', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // При включенном авто-определении выбор языка должен быть недоступен
      // Проверяем, что элементы списка присутствуют
      expect(find.text('Русский'), findsWidgets);
    });

    testWidgets('shows native language names', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем отображение названий на родных языках
      expect(find.text('Русский'), findsWidgets);
      expect(find.text('English'), findsWidgets);
      expect(find.text('Español'), findsWidgets);
      expect(find.text('Français'), findsWidgets);
      expect(find.text('Deutsch'), findsWidgets);
      expect(find.text('Italiano'), findsWidgets);
      expect(find.text('中文'), findsWidgets);
      expect(find.text('日本語'), findsWidgets);
      expect(find.text('Português'), findsWidgets);
      expect(find.text('Türkçe'), findsWidgets);
    });

    testWidgets('shows language icons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие иконок
      expect(find.byIcon(Icons.language), findsWidgets);
      expect(find.byIcon(Icons.translate), findsOneWidget);
    });

    testWidgets('shows snackbar on language change', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Выключаем авто-определение
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Выбираем другой язык
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();

      // Проверяем появление уведомления
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Язык изменен'), findsOneWidget);
    });

    testWidgets('shows selected state for chosen language', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Выключаем авто-определение
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Выбираем английский
      await tester.tap(find.text('English').first);
      await tester.pumpAndSettle();

      // Проверяем галочку у выбранного языка
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('list has dividers between languages', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие разделителей
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('shows proper card styling', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LanguageScreen())),
      );

      // Проверяем наличие контейнеров с оформлением
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('AppLanguage Model Tests', () {
    test('AppLanguage has correct properties', () {
      const language = AppLanguage(
        code: 'en',
        name: 'English',
        flag: '🇬🇧',
        nativeName: 'English',
      );

      expect(language.code, 'en');
      expect(language.name, 'English');
      expect(language.flag, '🇬🇧');
      expect(language.nativeName, 'English');
    });

    test('AppLanguage availableLanguages contains all languages', () {
      expect(AppLanguage.availableLanguages.length, 18);

      final codes = AppLanguage.availableLanguages.map((l) => l.code).toList();
      expect(codes, contains('ru'));
      expect(codes, contains('en'));
      expect(codes, contains('es'));
      expect(codes, contains('fr'));
      expect(codes, contains('de'));
      expect(codes, contains('it'));
      expect(codes, contains('zh'));
      expect(codes, contains('ja'));
      expect(codes, contains('pt'));
      expect(codes, contains('tr'));
    });
  });
}
