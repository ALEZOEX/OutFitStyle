import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_category.dart';

/// DTO для ответа API со списком достижений
class AchievementsResponse {
  final List<AchievementDto> achievements;

  AchievementsResponse({required this.achievements});

  factory AchievementsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['achievements'] as List? ?? [];
    return AchievementsResponse(
      achievements: list
          .map((item) => AchievementDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Конвертировать в доменные сущности
  List<Achievement> toDomain() {
    return achievements.map((dto) => dto.toDomain()).toList();
  }
}

/// DTO для ответа API с достижениями пользователя
class UserAchievementsResponse {
  final List<AchievementDto> unlocked;
  final List<AchievementDto> inProgress;
  final int totalPoints;
  final String rank;

  UserAchievementsResponse({
    required this.unlocked,
    required this.inProgress,
    required this.totalPoints,
    required this.rank,
  });

  factory UserAchievementsResponse.fromJson(Map<String, dynamic> json) {
    final unlockedList = json['unlocked'] as List? ?? [];
    final inProgressList = json['in_progress'] as List? ?? [];

    return UserAchievementsResponse(
      unlocked: unlockedList
          .map((item) => AchievementDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      inProgress: inProgressList
          .map((item) => AchievementDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPoints: json['total_points'] as int? ?? 0,
      rank: json['rank'] as String? ?? 'bronze',
    );
  }

  /// Конвертировать в доменные сущности
  UserAchievementsData toDomain() {
    return UserAchievementsData(
      unlocked: unlocked.map((dto) => dto.toDomain()).toList(),
      inProgress: inProgress.map((dto) => dto.toDomain()).toList(),
      totalPoints: totalPoints,
      rank: rank,
    );
  }
}

/// Данные достижений пользователя
class UserAchievementsData {
  final List<Achievement> unlocked;
  final List<Achievement> inProgress;
  final int totalPoints;
  final String rank;

  UserAchievementsData({
    required this.unlocked,
    required this.inProgress,
    required this.totalPoints,
    required this.rank,
  });

  /// Получить общий прогресс
  int get unlockedCount => unlocked.length;

  /// Получить процент выполнения
  double get progressPercent {
    final total = unlocked.length + inProgress.length;
    if (total == 0) return 0;
    return (unlocked.length / total * 100);
  }
}

/// DTO отдельного достижения
class AchievementDto {
  final String id;
  final String code;
  final String name;
  final String description;
  final String iconEmoji;
  final int points;
  final DateTime? unlockedAt;
  final int? progress;
  final String? status;

  AchievementDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.points,
    this.unlockedAt,
    this.progress,
    this.status,
  });

  factory AchievementDto.fromJson(Map<String, dynamic> json) {
    return AchievementDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconEmoji: json['icon_emoji'] as String,
      points: json['points'] as int,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      progress: json['progress'] as int?,
      status: json['status'] as String?,
    );
  }

  /// Конвертировать в доменную сущность
  Achievement toDomain() {
    // Определяем категорию по коду (префикс до первого _)
    final category = _parseCategoryFromCode(code);
    
    // Определяем целевое значение из прогресса или по умолчанию 1
    final targetValue = progress != null && progress! > 1 ? progress! : 1;
    final currentProgress = progress ?? 0;
    final isUnlocked = status == 'unlocked' || unlockedAt != null;

    return Achievement(
      id: id,
      title: name,
      description: description,
      icon: iconEmoji,
      category: category,
      points: points,
      currentProgress: currentProgress,
      targetValue: targetValue,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      createdAt: unlockedAt,
      updatedAt: unlockedAt,
    );
  }

  /// Парсинг категории из кода достижения
  /// Например: 'wardrobe_10' -> AchievementCategory.wardrobe
  AchievementCategory _parseCategoryFromCode(String code) {
    // Стартовые достижения
    if (code.startsWith('first_')) {
      return AchievementCategory.starter;
    }

    // Гардероб
    if (code.startsWith('wardrobe_') || 
        code == 'all_categories' || 
        code == 'favorite_hunter' ||
        code.startsWith('family_')) {
      return AchievementCategory.wardrobe;
    }

    // Рекомендации
    if (code.startsWith('recommendation_') ||
        code == 'perfect_week' ||
        code == 'perfect_month' ||
        code == 'high_rated') {
      return AchievementCategory.recommendations;
    }

    // Погода
    if (code.contains('weather') ||
        code.contains('winter') ||
        code.contains('summer') ||
        code.contains('rainy') ||
        code.contains('snowy') ||
        code == 'all_seasons') {
      return AchievementCategory.weather;
    }

    // Время
    if (code.contains('week') ||
        code.contains('month') ||
        code.contains('year') ||
        code.contains('daily') ||
        code == 'early_bird' ||
        code == 'night_owl') {
      return AchievementCategory.time;
    }

    // Планирование
    if (code.contains('planner') || code.contains('event_')) {
      return AchievementCategory.planning;
    }

    // Оценки
    if (code.contains('rating') ||
        code == 'critic' ||
        code == 'positive' ||
        code == 'honest' ||
        code == 'perfect_rating') {
      return AchievementCategory.ratings;
    }

    // Семья
    if (code.startsWith('family_')) {
      return AchievementCategory.family;
    }

    // Особые
    if (code == 'perfectionist' ||
        code == 'minimalist' ||
        code == 'colorful' ||
        code == 'monochrome' ||
        code == 'brand_collector' ||
        code == 'seasonal' ||
        code == 'trendsetter') {
      return AchievementCategory.special;
    }

    // По умолчанию
    return AchievementCategory.special;
  }
}
