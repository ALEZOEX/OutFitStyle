import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:outfitstyle_client/app/app.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: OutfitStyleApp(),
      ),
    );

    // Verify that our app starts
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
