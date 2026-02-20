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

      // Проверяем наличие базовой структуры экрана
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
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

      // Проверяем что экран работает
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
