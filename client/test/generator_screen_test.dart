import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/features/generator/presentation/generator_screen.dart';

void main() {
  group('GeneratorScreen Tests', () {
    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GeneratorScreen(),
          ),
        ),
      );

      // Проверяем, что экран отображается без ошибок
      expect(find.byType(GeneratorScreen), findsOneWidget);
    });
  });
}