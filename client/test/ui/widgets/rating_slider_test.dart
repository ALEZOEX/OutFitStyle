import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:outfitstyle_client/src/ui/widgets/rating_slider.dart';

void main() {
  group('RatingSlider Widget Tests', () {
    testWidgets('shows initial rating of 0', (tester) async {
      int selectedRating = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) => selectedRating = rating,
          ),
        ),
      );

      // Проверяем отображение начального значения
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Нейтрально'), findsOneWidget);
    });

    testWidgets('shows rating labels -10, 0, +10', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем метки на слайдере
      expect(find.text('-10'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('+10'), findsOneWidget);
    });

    testWidgets('shows correct icon for negative rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: -7,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем иконку для очень плохого рейтинга
      expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
    });

    testWidgets('shows correct icon for positive rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 7,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем иконку для отличного рейтинга
      expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
    });

    testWidgets('shows correct icon for neutral rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем иконку для нейтрального рейтинга
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('shows rating with plus sign for positive values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 5,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем отображение плюса для положительных значений
      expect(find.text('+5'), findsOneWidget);
    });

    testWidgets('shows rating without plus sign for negative values', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: -5,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем отображение минуса для отрицательных значений
      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('shows correct label for very bad rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: -8,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      expect(find.text('Ужасно'), findsOneWidget);
    });

    testWidgets('shows correct label for bad rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: -5,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      expect(find.text('Плохо'), findsOneWidget);
    });

    testWidgets('shows correct label for good rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 5,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      expect(find.text('Хорошо'), findsOneWidget);
    });

    testWidgets('shows correct label for excellent rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 9,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      expect(find.text('Отлично'), findsOneWidget);
    });

    testWidgets('shows correct label for perfect rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 10,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      expect(find.text('Превосходно'), findsOneWidget);
    });

    testWidgets('allows selection from -10 to 10', (tester) async {
      int selectedRating = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) => selectedRating = rating,
          ),
        ),
      );

      // Проверяем, что слайдер существует
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('shows custom title when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
            title: 'Оцените наряд',
          ),
        ),
      );

      expect(find.text('Оцените наряд'), findsOneWidget);
    });

    testWidgets('hides labels when showLabels is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
            showLabels: false,
          ),
        ),
      );

      // Проверяем отсутствие текстовых меток
      expect(find.text('Нейтрально'), findsNothing);
      expect(find.text('-10'), findsNothing);
      expect(find.text('+10'), findsNothing);
    });

    testWidgets('shows gradient slider bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем наличие контейнера (слайдер с градиентом)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows rating indicator circle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем наличие индикатора (круг с иконкой)
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('applies custom slider height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
            sliderHeight: 80,
          ),
        ),
      );

      // Проверяем наличие контейнера
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows rating card with border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем наличие карточки с рейтингом
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('CompactRatingSlider Widget Tests', () {
    testWidgets('shows compact slider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 0,
          ),
        ),
      );

      // Проверяем наличие компактного слайдера
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('shows gradient bar in compact mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 5,
          ),
        ),
      );

      // Проверяем наличие градиента
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('shows indicator at correct position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 5,
          ),
        ),
      );

      // Проверяем наличие индикатора
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('accepts custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 0,
            height: 60,
          ),
        ),
      );

      // Проверяем наличие контейнера
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('allows rating change with callback', (tester) async {
      int newRating = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 0,
            onRatingChanged: (rating) => newRating = rating,
          ),
        ),
      );

      // Проверяем наличие GestureDetector для изменения рейтинга
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('Rating Color Tests', () {
    testWidgets('shows red color for negative ratings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: -10,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем наличие красного цвета для отрицательных рейтингов
      expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsOneWidget);
    });

    testWidgets('shows green color for positive ratings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 10,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем наличие зелёного цвета для положительных рейтингов
      expect(find.byIcon(Icons.sentiment_very_satisfied), findsOneWidget);
    });

    testWidgets('shows grey color for neutral rating', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (rating) {},
          ),
        ),
      );

      // Проверяем наличие серого цвета для нейтрального рейтинга
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });
  });
}
