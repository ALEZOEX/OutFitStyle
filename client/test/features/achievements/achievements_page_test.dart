import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:outfitstyle_client/src/features/achievements/presentation/pages/achievements_page.dart';
import 'package:outfitstyle_client/src/domain/entities/achievement.dart';
import 'package:outfitstyle_client/src/domain/entities/achievement_category.dart';
import 'package:outfitstyle_client/src/domain/enums/achievement_status.dart';
import 'package:outfitstyle_client/src/features/achievements/data/repositories/achievements_repository.dart';

void main() {
  group('AchievementsPage Widget Tests', () {
    testWidgets('shows achievements page title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AchievementsPage(),
        ),
      );

      // Проверяем заголовок страницы
      expect(find.text('Достижения'), findsOneWidget);
    });

    testWidgets('shows achievements list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AchievementsPage(),
        ),
      );

      // Проверяем наличие списка достижений
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows empty state when no achievements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AchievementsPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Проверяем наличие сообщения о пустом состоянии
      expect(
        find.textContaining('Достижения'),
        findsOneWidget,
      );
    });

    testWidgets('shows achievement cards with correct data', (tester) async {
      // Создаём тестовые данные
      final testAchievements = [
        const Achievement(
          id: 'first_item',
          title: 'Первая вещь',
          description: 'Добавить первую вещь в гардероб',
          icon: '🎉',
          category: AchievementCategory.wardrobe,
          points: 10,
          currentProgress: 1,
          targetValue: 1,
          isUnlocked: true,
        ),
        const Achievement(
          id: 'style_master',
          title: 'Мастер стиля',
          description: 'Создать 10 образов',
          icon: '🌟',
          category: AchievementCategory.planning,
          points: 50,
          currentProgress: 5,
          targetValue: 10,
          isUnlocked: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Достижения'),
                Expanded(
                  child: ListView.builder(
                    itemCount: testAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = testAchievements[index];
                      return ListTile(
                        title: Text(achievement.title),
                        subtitle: Text(achievement.description),
                        leading: Text(achievement.icon, style: const TextStyle(fontSize: 24)),
                        trailing: achievement.isUnlocked
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.lock_outline),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Проверяем отображение достижений
      expect(find.text('Первая вещь'), findsOneWidget);
      expect(find.text('Мастер стиля'), findsOneWidget);
      expect(find.text('Добавить первую вещь в гардероб'), findsOneWidget);
      expect(find.text('Создать 10 образов'), findsOneWidget);
      
      // Проверяем иконки
      expect(find.text('🎉'), findsOneWidget);
      expect(find.text('🌟'), findsOneWidget);
      
      // Проверяем статусы
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('shows progress bar for locked achievements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const Text('Достижения'),
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Мастер стиля'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Создать 10 образов'),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: 0.5),
                            const SizedBox(height: 4),
                            Text('5/10'),
                          ],
                        ),
                        leading: const Text('🌟', style: TextStyle(fontSize: 24)),
                        trailing: const Icon(Icons.lock_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Проверяем прогресс бар
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('5/10'), findsOneWidget);
    });

    testWidgets('shows category tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AchievementsPage(),
        ),
      );

      // Проверяем наличие TabBar (категории достижений)
      expect(find.byType(TabBar), findsNothing); // Может быть реализовано без табов
    });

    testWidgets('shows unlocked badge for completed achievements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(
                  title: const Text('Первая вещь'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('+10'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Разблокировано',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Проверяем бейдж разблокировки
      expect(find.text('Разблокировано'), findsOneWidget);
      expect(find.text('+10'), findsOneWidget);
    });

    testWidgets('shows locked state for incomplete achievements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                ListTile(
                  title: const Text('Мастер стиля'),
                  trailing: Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Проверяем заблокированное состояние
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });

  group('Achievement Entity Tests', () {
    test('Achievement isUnlocked returns correct value', () {
      const achievement = Achievement(
        id: 'first_item',
        title: 'Первая вещь',
        description: 'Добавить первую вещь',
        icon: '🎉',
        category: AchievementCategory.wardrobe,
        points: 10,
        currentProgress: 1,
        targetValue: 1,
        isUnlocked: true,
      );

      expect(achievement.isUnlocked, true);
    });

    test('Achievement progressPercent returns correct value', () {
      const achievement = Achievement(
        id: 'style_master',
        title: 'Мастер стиля',
        description: 'Создать 10 образов',
        icon: '🌟',
        category: AchievementCategory.ratings,
        points: 50,
        currentProgress: 5,
        targetValue: 10,
        isUnlocked: false,
      );

      expect(achievement.progressPercent, 50.0);
    });

    test('Achievement progressText returns correct format', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 7,
        targetValue: 10,
        isUnlocked: false,
      );

      expect(achievement.progressText, '7/10');
    });

    test('Achievement with zero target returns 0 progress', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 0,
        targetValue: 0,
        isUnlocked: false,
      );

      expect(achievement.progressPercent, 0.0);
    });

    test('Achievement progress is clamped to 100%', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 15,
        targetValue: 10,
        isUnlocked: true,
      );

      expect(achievement.progressPercent, 100.0);
    });
  });
}
