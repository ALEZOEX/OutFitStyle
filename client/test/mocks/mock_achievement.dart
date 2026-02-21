import 'package:outfitstyle_client/src/domain/entities/achievement.dart';
import 'package:outfitstyle_client/src/domain/entities/achievement_category.dart';

/// Тестовые данные для достижений
class MockAchievement {
  /// Создать тестовое достижение
  static Achievement create({
    String id = 'test_achievement',
    String title = 'Тестовое достижение',
    String description = 'Описание тестового достижения',
    String icon = '🎯',
    AchievementCategory category = AchievementCategory.starter,
    int points = 10,
    int currentProgress = 0,
    int targetValue = 1,
    bool isUnlocked = false,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      category: category,
      points: points,
      currentProgress: currentProgress,
      targetValue: targetValue,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }

  /// Список тестовых достижений
  static List<Achievement> createList({int count = 5}) {
    final categories = AchievementCategory.values;
    final icons = ['🏆', '🎯', '⭐', '🎉', '🌟', '🔥', '💎', '👑'];
    final titles = [
      'Первый шаг',
      'Любитель',
      'Профессионал',
      'Эксперт',
      'Мастер',
      'Легенда',
      'Чемпион',
      'Икона стиля',
    ];

    return List.generate(count, (index) => create(
      id: 'achievement_$index',
      title: titles[index % titles.length],
      description: 'Описание достижения $index',
      icon: icons[index % icons.length],
      category: categories[index % categories.length],
      points: (index + 1) * 10,
      currentProgress: index,
      targetValue: 10,
      isUnlocked: index < 3,
      unlockedAt: index < 3 ? DateTime.now().subtract(Duration(days: index)) : null,
    ));
  }

  /// Достижение в процессе выполнения
  static Achievement inProgress() {
    return create(
      id: 'in_progress',
      title: 'В процессе',
      description: 'Достижение в процессе выполнения',
      icon: '⏳',
      currentProgress: 5,
      targetValue: 10,
      isUnlocked: false,
    );
  }

  /// Разблокированное достижение
  static Achievement unlocked() {
    return create(
      id: 'unlocked',
      title: 'Разблокировано',
      description: 'Уже разблокированное достижение',
      icon: '🏆',
      currentProgress: 10,
      targetValue: 10,
      isUnlocked: true,
      unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
      points: 100,
    );
  }

  /// Заблокированное достижение
  static Achievement locked() {
    return create(
      id: 'locked',
      title: 'Заблокировано',
      description: 'Ещё не открытое достижение',
      icon: '🔒',
      currentProgress: 0,
      targetValue: 5,
      isUnlocked: false,
      points: 50,
    );
  }

  /// Достижение для категории Wardrobe
  static Achievement wardrobeAchievement() {
    return create(
      id: 'first_item',
      title: 'Первая вещь',
      description: 'Добавить первую вещь в гардероб',
      icon: '👕',
      category: AchievementCategory.wardrobe,
      points: 10,
      currentProgress: 1,
      targetValue: 1,
      isUnlocked: true,
    );
  }

  /// Достижение для категории Ratings
  static Achievement ratingAchievement() {
    return create(
      id: 'critic',
      title: 'Критик',
      description: 'Оценить 50 рекомендаций',
      icon: '⭐',
      category: AchievementCategory.ratings,
      points: 50,
      currentProgress: 25,
      targetValue: 50,
      isUnlocked: false,
    );
  }

  /// Достижение для категории Planning
  static Achievement planningAchievement() {
    return create(
      id: 'week_planner',
      title: 'Недельный планировщик',
      description: 'Создать 7 образов на неделю',
      icon: '📅',
      category: AchievementCategory.planning,
      points: 70,
      currentProgress: 4,
      targetValue: 7,
      isUnlocked: false,
    );
  }
}
