import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:outfitstyle/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';
import 'package:outfitstyle/features/wardrobe/domain/models/wardrobe_item.dart';

class MockWardrobeItem extends Mock implements WardrobeItem {}

void main() {
  late WardrobeItem mockItem;

  setUp(() {
    mockItem = MockWardrobeItem();
    when(() => mockItem.id).thenReturn('item-1');
    when(() => mockItem.name).thenReturn('Blue T-Shirt');
    when(() => mockItem.category).thenReturn('top');
    when(() => mockItem.color).thenReturn('blue');
    when(() => mockItem.imageUrl).thenReturn('https://example.com/image.jpg');
    when(() => mockItem.warmthLevel).thenReturn(2);
    when(() => mockItem.createdAt).thenReturn(DateTime.now());
  });

  group('WardrobeItemCard', () {
    testWidgets('displays item information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WardrobeItemCard(
              item: mockItem,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('Blue T-Shirt'), findsOneWidget);
      expect(find.text('top'), findsOneWidget);
      expect(find.text('blue'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapCalled = false;
      void onTap() => tapCalled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WardrobeItemCard(
              item: mockItem,
              onTap: onTap,
              onLongPress: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(tapCalled, isTrue);
    });

    testWidgets('calls onLongPress when card is long pressed', (tester) async {
      var longPressCalled = false;
      void onLongPress() => longPressCalled = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WardrobeItemCard(
              item: mockItem,
              onTap: () {},
              onLongPress: onLongPress,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(Card));
      await tester.pump();

      expect(longPressCalled, isTrue);
    });

    testWidgets('displays warmth level indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WardrobeItemCard(
              item: mockItem,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      // Check that warmth level is displayed (2 stars for warmth level 2)
      expect(find.byIcon(Icons.star), findsNWidgets(2));
      expect(find.byIcon(Icons.star_border), findsNWidgets(3)); // 5 total
    });

    testWidgets('handles null image URL gracefully', (tester) async {
      when(() => mockItem.imageUrl).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WardrobeItemCard(
              item: mockItem,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      );

      // Should show placeholder instead of image
      expect(find.byType(Image), findsNothing);
      expect(find.byType(Icon), findsOneWidget); // Placeholder icon
    });
  });
}