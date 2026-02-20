import 'package:flutter_test/flutter_test.dart';

import 'package:outfitstyle_client/src/domain/entities/achievement.dart';
import 'package:outfitstyle_client/src/domain/entities/achievement_category.dart';

void main() {
  group('Achievement Entity Tests', () {
    test('Achievement creates with correct properties', () {
      const achievement = Achievement(
        id: 'first_item',
        title: 'Первая вещь',
        description: 'Добавить первую вещь в гардероб',
        icon: '🎉',
        category: AchievementCategory.wardrobe,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
        isUnlocked: false,
      );

      expect(achievement.id, 'first_item');
      expect(achievement.title, 'Первая вещь');
      expect(achievement.description, 'Добавить первую вещь в гардероб');
      expect(achievement.icon, '🎉');
      expect(achievement.category, AchievementCategory.wardrobe);
      expect(achievement.points, 10);
      expect(achievement.currentProgress, 0);
      expect(achievement.targetValue, 1);
      expect(achievement.isUnlocked, false);
    });

    test('Achievement isUnlocked returns true when unlocked', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 1,
        targetValue: 1,
        isUnlocked: true,
      );

      expect(achievement.isUnlocked, true);
    });

    test('Achievement isUnlocked returns false when locked', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
        isUnlocked: false,
      );

      expect(achievement.isUnlocked, false);
    });

    test('Achievement progressPercent returns 0 for zero target', () {
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

    test('Achievement progressPercent returns correct percentage', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 5,
        targetValue: 10,
        isUnlocked: false,
      );

      expect(achievement.progressPercent, 50.0);
    });

    test('Achievement progressPercent clamps to 100', () {
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

    test('Achievement progressText works with zero values', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 0,
        targetValue: 10,
        isUnlocked: false,
      );

      expect(achievement.progressText, '0/10');
    });

    test('Achievement categoryIcon returns category icon', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.wardrobe,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
        isUnlocked: false,
      );

      expect(achievement.categoryIcon, '👕');
    });

    test('Achievement categoryDisplayName returns category name', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.wardrobe,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
        isUnlocked: false,
      );

      expect(achievement.categoryDisplayName, 'Гардероб');
    });

    test('Achievement copyWith creates modified copy', () {
      const original = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
        isUnlocked: false,
      );

      final modified = original.copyWith(
        currentProgress: 1,
        isUnlocked: true,
      );

      expect(modified.currentProgress, 1);
      expect(modified.isUnlocked, true);
      expect(modified.id, 'test');
    });
  });

  group('AchievementCategory Tests', () {
    test('AchievementCategory wardrobe has correct properties', () {
      expect(AchievementCategory.wardrobe.icon, '👕');
      expect(AchievementCategory.wardrobe.displayName, 'Гардероб');
      expect(AchievementCategory.wardrobe.id, 'wardrobe');
    });

    test('AchievementCategory recommendations has correct properties', () {
      expect(AchievementCategory.recommendations.icon, '✨');
      expect(AchievementCategory.recommendations.displayName, 'Рекомендации');
      expect(AchievementCategory.recommendations.id, 'recommendations');
    });

    test('AchievementCategory weather has correct properties', () {
      expect(AchievementCategory.weather.icon, '🌤️');
      expect(AchievementCategory.weather.displayName, 'Погода');
      expect(AchievementCategory.weather.id, 'weather');
    });

    test('AchievementCategory ratings has correct properties', () {
      expect(AchievementCategory.ratings.icon, '⭐');
      expect(AchievementCategory.ratings.displayName, 'Оценки');
      expect(AchievementCategory.ratings.id, 'ratings');
    });

    test('AchievementCategory special has correct properties', () {
      expect(AchievementCategory.special.icon, '🏅');
      expect(AchievementCategory.special.displayName, 'Особые');
      expect(AchievementCategory.special.id, 'special');
    });

    test('AchievementCategory starter has correct properties', () {
      expect(AchievementCategory.starter.icon, '🎯');
      expect(AchievementCategory.starter.displayName, 'Старт');
      expect(AchievementCategory.starter.id, 'starter');
    });

    test('AchievementCategory fromId returns correct category', () {
      expect(AchievementCategory.fromId('wardrobe'), AchievementCategory.wardrobe);
      expect(AchievementCategory.fromId('ratings'), AchievementCategory.ratings);
      expect(AchievementCategory.fromId('unknown'), AchievementCategory.special);
    });

    test('AchievementCategory allCategories returns all values', () {
      expect(AchievementCategory.allCategories.length, AchievementCategory.values.length);
    });
  });

  group('Achievement Progress Extension Tests', () {
    test('progressPercent returns 0 for empty progress', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 0,
        targetValue: 10,
        isUnlocked: false,
      );

      expect(achievement.progressPercent, 0.0);
    });

    test('progressPercent returns 25 for quarter progress', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 2,
        targetValue: 8,
        isUnlocked: false,
      );

      expect(achievement.progressPercent, 25.0);
    });

    test('progressPercent returns 75 for three quarters progress', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 75,
        targetValue: 100,
        isUnlocked: false,
      );

      expect(achievement.progressPercent, 75.0);
    });

    test('progressText shows correct format', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 42,
        targetValue: 100,
        isUnlocked: false,
      );

      expect(achievement.progressText, '42/100');
    });
  });

  group('Achievement fromJson toJson Tests', () {
    test('Achievement fromJson creates correct object', () {
      final json = {
        'id': 'first_item',
        'title': 'Первая вещь',
        'description': 'Добавить первую вещь',
        'icon': '🎉',
        'category': 'wardrobe',
        'points': 10,
        'currentProgress': 1,
        'targetValue': 1,
        'isUnlocked': true,
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.id, 'first_item');
      expect(achievement.title, 'Первая вещь');
      expect(achievement.description, 'Добавить первую вещь');
      expect(achievement.icon, '🎉');
      expect(achievement.points, 10);
      expect(achievement.currentProgress, 1);
      expect(achievement.targetValue, 1);
      expect(achievement.isUnlocked, true);
    });

    test('Achievement fromJson handles default values', () {
      final json = {
        'id': 'test',
        'title': 'Test',
        'description': 'Test',
        'icon': '🎯',
        'category': 'ratings',
        'points': 10,
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.currentProgress, 0);
      expect(achievement.targetValue, 1);
      expect(achievement.isUnlocked, false);
    });

    test('Achievement toJson creates correct JSON', () {
      const achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🎯',
        category: AchievementCategory.ratings,
        points: 10,
        currentProgress: 5,
        targetValue: 10,
        isUnlocked: false,
      );

      final json = achievement.toJson();

      expect(json['id'], 'test');
      expect(json['title'], 'Test');
      expect(json['description'], 'Test');
      expect(json['icon'], '🎯');
      expect(json['points'], 10);
      expect(json['currentProgress'], 5);
      expect(json['targetValue'], 10);
      expect(json['isUnlocked'], false);
    });
  });
}
