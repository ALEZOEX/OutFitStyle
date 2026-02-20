/// Категории достижений в приложении OutfitStyle
enum AchievementCategory {
  /// Гардероб - достижения связанные с добавлением вещей
  wardrobe('wardrobe', 'Гардероб', '👕'),

  /// Рекомендации - достижения за использование рекомендаций
  recommendations('recommendations', 'Рекомендации', '✨'),

  /// Погода - достижения связанные с погодными условиями
  weather('weather', 'Погода', '🌤️'),

  /// Время в приложении - достижения за активность по времени
  time('time', 'Время', '⏰'),

  /// Планирование - достижения за планирование образов
  planning('planning', 'Планирование', '📅'),

  /// Оценки - достижения за оценку рекомендаций
  ratings('ratings', 'Оценки', '⭐'),

  /// Семейные - достижения связанные с семьей
  family('family', 'Семья', '👨‍👩‍👧'),

  /// Подписка - достижения за подписку
  subscription('subscription', 'Подписка', '💎'),

  /// Особые - специальные достижения
  special('special', 'Особые', '🏅'),

  /// Стартовые - достижения для новичков
  starter('starter', 'Старт', '🎯');

  /// Технический идентификатор категории
  final String id;

  /// Отображаемое название категории
  final String displayName;

  /// Иконка категории (emoji)
  final String icon;

  const AchievementCategory(this.id, this.displayName, this.icon);

  /// Получить категорию по ID
  static AchievementCategory fromId(String id) {
    return AchievementCategory.values.firstWhere(
      (e) => e.id == id,
      orElse: () => AchievementCategory.special,
    );
  }

  /// Получить все категории для UI
  static List<AchievementCategory> get allCategories => AchievementCategory.values;
}
