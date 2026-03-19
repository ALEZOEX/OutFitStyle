import 'package:freezed_annotation/freezed_annotation.dart';
import 'achievement_category.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Достижение пользователя в приложении OutfitStyle
@freezed
abstract class Achievement with _$Achievement {
  const factory Achievement({
    /// Уникальный идентификатор достижения
    required String id,

    /// Заголовок достижения
    required String title,

    /// Описание достижения
    required String description,

    /// Иконка достижения (emoji или название иконки)
    required String icon,

    /// Категория достижения
    required AchievementCategory category,

    /// Количество очков за достижение
    required int points,

    /// Текущий прогресс выполнения
    @Default(0) int currentProgress,

    /// Целевое значение для завершения
    @Default(1) int targetValue,

    /// Разблокировано ли достижение
    @Default(false) bool isUnlocked,

    /// Дата разблокировки достижения
    DateTime? unlockedAt,

    /// Дата создания записи о достижении
    DateTime? createdAt,

    /// Дата последнего обновления
    DateTime? updatedAt,

    /// ID пользователя (если привязано к конкретному пользователю)
    String? userId,

    /// Награда за достижение (например, бонусные очки)
    @Default('') String reward,

    /// Видимо ли достижение в списке
    @Default(true) bool isVisible,

    /// Тип достижения для трекинга
    String? type,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Расширение для получения процента прогресса достижения
extension AchievementProgressExtension on Achievement {
  /// Процент выполнения прогресса (0-100)
  double get progressPercent {
    if (targetValue <= 0) return 0;
    return ((currentProgress / targetValue) * 100).clamp(0, 100);
  }

  /// Отображаемый прогресс в формате "X/Y"
  String get progressText => '$currentProgress/$targetValue';

  /// Получение иконки категории
  String get categoryIcon => category.icon;

  /// Получение названия категории
  String get categoryDisplayName => category.displayName;
}
