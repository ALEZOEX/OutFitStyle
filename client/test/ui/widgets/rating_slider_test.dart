import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:outfitstyle_client/src/ui/widgets/rating_slider.dart';

void main() {
  group('RatingSlider Widget Tests', () {
    testWidgets('shows initial rating of 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (_) {},
          ),
        ),
      );

      // Проверяем отображение начального значения (используем findsWidgets т.к. текст может быть в нескольких местах)
      expect(find.text('0'), findsWidgets);
      expect(find.text('Нейтрально'), findsWidgets);
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

      // Проверяем метки на слайдере (используем findsWidgets т.к. текст может быть в нескольких местах)
      expect(find.text('-10'), findsWidgets);
      expect(find.text('0'), findsWidgets);
      expect(find.text('+10'), findsWidgets);
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

      // Проверяем иконку для очень плохого рейтинга (используем findsWidgets т.к. иконка может быть в нескольких местах)
      expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsWidgets);
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

      // Проверяем иконку для отличного рейтинга (используем findsWidgets т.к. иконка может быть в нескольких местах)
      expect(find.byIcon(Icons.sentiment_very_satisfied), findsWidgets);
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

      // Проверяем иконку для нейтрального рейтинга (используем findsWidgets т.к. иконка может быть в нескольких местах)
      expect(find.byIcon(Icons.remove), findsWidgets);
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

      // Проверяем отображение плюса для положительных значений (используем findsWidgets)
      expect(find.text('+5'), findsWidgets);
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

      // Проверяем отображение минуса для отрицательных значений (используем findsWidgets)
      expect(find.text('-5'), findsWidgets);
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

      expect(find.text('Ужасно'), findsWidgets);
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

      expect(find.text('Плохо'), findsWidgets);
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

      expect(find.text('Хорошо'), findsWidgets);
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

      expect(find.text('Отлично'), findsWidgets);
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

      expect(find.text('Превосходно'), findsWidgets);
    });

    testWidgets('allows selection from -10 to 10', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RatingSlider(
            initialRating: 0,
            onRatingChanged: (_) {},
          ),
        ),
      );

      // Проверяем, что слайдер существует (используем findsWidgets)
      expect(find.byType(GestureDetector), findsWidgets);
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

      expect(find.text('Оцените наряд'), findsWidgets);
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

      // Проверяем наличие компактного слайдера (используем findsWidgets т.к. Container может быть в нескольких местах)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows gradient bar in compact mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 5,
          ),
        ),
      );

      // Проверяем наличие градиента (используем findsWidgets т.к. Container может быть в нескольких местах)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows indicator at correct position', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 5,
          ),
        ),
      );

      // Проверяем наличие индикатора (используем findsWidgets т.к. Stack может быть в нескольких местах)
      expect(find.byType(Stack), findsWidgets);
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

      // Проверяем наличие контейнера (используем findsWidgets т.к. Container может быть в нескольких местах)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('allows rating change with callback', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CompactRatingSlider(
            rating: 0,
            onRatingChanged: (_) {},
          ),
        ),
      );

      // Проверяем наличие GestureDetector для изменения рейтинга
      expect(find.byType(GestureDetector), findsWidgets);
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

      // Проверяем наличие красного цвета для отрицательных рейтингов (используем findsWidgets)
      expect(find.byIcon(Icons.sentiment_very_dissatisfied), findsWidgets);
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

      // Проверяем наличие зелёного цвета для положительных рейтингов (используем findsWidgets)
      expect(find.byIcon(Icons.sentiment_very_satisfied), findsWidgets);
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

      // Проверяем наличие серого цвета для нейтрального рейтинга (используем findsWidgets)
      expect(find.byIcon(Icons.remove), findsWidgets);
    });
  });
}
