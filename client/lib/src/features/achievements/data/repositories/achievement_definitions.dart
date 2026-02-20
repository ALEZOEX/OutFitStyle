import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_category.dart';

/// Определения всех достижений в приложении OutfitStyle
/// Всего 50+ достижений в 10 категориях
class AchievementDefinitions {
  AchievementDefinitions._();

  /// Получить все определения достижений
  static List<Achievement> getAllAchievements() {
    return [
      // ============================================
      // СТАРТОВЫЕ ДОСТИЖЕНИЯ (Starter)
      // ============================================
      const Achievement(
        id: 'first_item',
        title: 'Первая вещь',
        description: 'Добавьте первую вещь в гардероб',
        icon: '🎯',
        category: AchievementCategory.starter,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'first_recommendation',
        title: 'Первый образ',
        description: 'Используйте первую рекомендацию',
        icon: '👔',
        category: AchievementCategory.starter,
        points: 15,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'first_rating',
        title: 'Первая оценка',
        description: 'Оцените первую рекомендацию',
        icon: '⭐',
        category: AchievementCategory.starter,
        points: 10,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'first_plan',
        title: 'Первый план',
        description: 'Запланируйте первый образ',
        icon: '📅',
        category: AchievementCategory.starter,
        points: 15,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'first_day',
        title: 'Первый день',
        description: 'Проведите первый день в приложении',
        icon: '🌅',
        category: AchievementCategory.starter,
        points: 20,
        currentProgress: 0,
        targetValue: 1,
      ),

      // ============================================
      // ГАРДЕРОБ (Wardrobe) - 8 достижений
      // ============================================
      const Achievement(
        id: 'wardrobe_10',
        title: 'Начинающий',
        description: 'Добавьте 10 вещей в гардероб',
        icon: '👕',
        category: AchievementCategory.wardrobe,
        points: 20,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'wardrobe_50',
        title: 'Любитель',
        description: 'Добавьте 50 вещей в гардероб',
        icon: '👔',
        category: AchievementCategory.wardrobe,
        points: 50,
        currentProgress: 0,
        targetValue: 50,
      ),
      const Achievement(
        id: 'wardrobe_100',
        title: 'Коллекционер',
        description: 'Добавьте 100 вещей в гардероб',
        icon: '🏆',
        category: AchievementCategory.wardrobe,
        points: 100,
        currentProgress: 0,
        targetValue: 100,
      ),
      const Achievement(
        id: 'wardrobe_500',
        title: 'Модник',
        description: 'Добавьте 500 вещей в гардероб',
        icon: '💎',
        category: AchievementCategory.wardrobe,
        points: 250,
        currentProgress: 0,
        targetValue: 500,
      ),
      const Achievement(
        id: 'wardrobe_1000',
        title: 'Гуру стиля',
        description: 'Добавьте 1000 вещей в гардероб',
        icon: '👑',
        category: AchievementCategory.wardrobe,
        points: 500,
        currentProgress: 0,
        targetValue: 1000,
      ),
      const Achievement(
        id: 'all_categories',
        title: 'Универсал',
        description: 'Имейте вещи во всех категориях одежды',
        icon: '🎨',
        category: AchievementCategory.wardrobe,
        points: 75,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'favorite_hunter',
        title: 'Избранное',
        description: 'Добавьте 50 вещей в избранное',
        icon: '❤️',
        category: AchievementCategory.wardrobe,
        points: 60,
        currentProgress: 0,
        targetValue: 50,
      ),
      const Achievement(
        id: 'family_first',
        title: 'Семьянин',
        description: 'Добавьте первого члена семьи',
        icon: '👨‍👩‍👧',
        category: AchievementCategory.wardrobe,
        points: 30,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'family_large',
        title: 'Большая семья',
        description: 'Добавьте 5 участников семьи',
        icon: '👨‍👩‍👧‍👦',
        category: AchievementCategory.wardrobe,
        points: 80,
        currentProgress: 0,
        targetValue: 5,
      ),

      // ============================================
      // РЕКОМЕНДАЦИИ (Recommendations) - 7 достижений
      // ============================================
      const Achievement(
        id: 'recommendation_10',
        title: 'Экспериментатор',
        description: 'Используйте 10 рекомендаций',
        icon: '✨',
        category: AchievementCategory.recommendations,
        points: 30,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'recommendation_50',
        title: 'Ценитель стиля',
        description: 'Используйте 50 рекомендаций',
        icon: '🌟',
        category: AchievementCategory.recommendations,
        points: 80,
        currentProgress: 0,
        targetValue: 50,
      ),
      const Achievement(
        id: 'recommendation_100',
        title: 'Икона стиля',
        description: 'Используйте 100 рекомендаций',
        icon: '💫',
        category: AchievementCategory.recommendations,
        points: 150,
        currentProgress: 0,
        targetValue: 100,
      ),
      const Achievement(
        id: 'perfect_week',
        title: 'Идеальная неделя',
        description: 'Используйте рекомендации 7 дней подряд',
        icon: '📆',
        category: AchievementCategory.recommendations,
        points: 100,
        currentProgress: 0,
        targetValue: 7,
      ),
      const Achievement(
        id: 'perfect_month',
        title: 'Идеальный месяц',
        description: 'Используйте рекомендации 30 дней подряд',
        icon: '🗓️',
        category: AchievementCategory.recommendations,
        points: 300,
        currentProgress: 0,
        targetValue: 30,
      ),
      const Achievement(
        id: 'high_rated',
        title: 'Вкусный выбор',
        description: 'Получите оценку +10 за образ',
        icon: '🔥',
        category: AchievementCategory.recommendations,
        points: 50,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'recommendation_500',
        title: 'Легенда стиля',
        description: 'Используйте 500 рекомендаций',
        icon: '🏅',
        category: AchievementCategory.recommendations,
        points: 500,
        currentProgress: 0,
        targetValue: 500,
      ),

      // ============================================
      // ПОГОДА (Weather) - 6 достижений
      // ============================================
      const Achievement(
        id: 'weather_pro',
        title: 'Погодный эксперт',
        description: 'Используйте рекомендации при 10 разных погодных условиях',
        icon: '🌤️',
        category: AchievementCategory.weather,
        points: 60,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'winter_warrior',
        title: 'Зимний воин',
        description: 'Носите рекомендации при -20°C',
        icon: '❄️',
        category: AchievementCategory.weather,
        points: 80,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'summer_lover',
        title: 'Летний любитель',
        description: 'Носите рекомендации при +30°C',
        icon: '☀️',
        category: AchievementCategory.weather,
        points: 80,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'rainy_day',
        title: 'Дождливый день',
        description: 'Носите рекомендации в дождь',
        icon: '🌧️',
        category: AchievementCategory.weather,
        points: 40,
        currentProgress: 0,
        targetValue: 5,
      ),
      const Achievement(
        id: 'snowy_day',
        title: 'Снежный день',
        description: 'Носите рекомендации в снегопад',
        icon: '🌨️',
        category: AchievementCategory.weather,
        points: 40,
        currentProgress: 0,
        targetValue: 5,
      ),
      const Achievement(
        id: 'all_seasons',
        title: 'Все сезоны',
        description: 'Используйте рекомендации во все 4 сезона',
        icon: '🔄',
        category: AchievementCategory.weather,
        points: 100,
        currentProgress: 0,
        targetValue: 4,
      ),

      // ============================================
      // ВРЕМЯ (Time) - 6 достижений
      // ============================================
      const Achievement(
        id: 'first_week',
        title: 'Первая неделя',
        description: 'Проведите 7 дней в приложении',
        icon: '📅',
        category: AchievementCategory.time,
        points: 50,
        currentProgress: 0,
        targetValue: 7,
      ),
      const Achievement(
        id: 'first_month',
        title: 'Первый месяц',
        description: 'Проведите 30 дней в приложении',
        icon: '🗓️',
        category: AchievementCategory.time,
        points: 100,
        currentProgress: 0,
        targetValue: 30,
      ),
      const Achievement(
        id: 'first_year',
        title: 'Первый год',
        description: 'Проведите 365 дней в приложении',
        icon: '🎉',
        category: AchievementCategory.time,
        points: 500,
        currentProgress: 0,
        targetValue: 365,
      ),
      const Achievement(
        id: 'early_bird',
        title: 'Жаворонок',
        description: 'Используйте приложение утром (6:00-10:00)',
        icon: '🌅',
        category: AchievementCategory.time,
        points: 30,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'night_owl',
        title: 'Сова',
        description: 'Используйте приложение ночью (22:00-02:00)',
        icon: '🌙',
        category: AchievementCategory.time,
        points: 30,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'daily_user',
        title: 'Ежедневный пользователь',
        description: 'Заходите в приложение 100 дней подряд',
        icon: '🔥',
        category: AchievementCategory.time,
        points: 200,
        currentProgress: 0,
        targetValue: 100,
      ),

      // ============================================
      // ПЛАНИРОВАНИЕ (Planning) - 4 достижения
      // ============================================
      const Achievement(
        id: 'week_planner',
        title: 'Недельный планировщик',
        description: 'Запланируйте образы на неделю',
        icon: '📆',
        category: AchievementCategory.planning,
        points: 50,
        currentProgress: 0,
        targetValue: 7,
      ),
      const Achievement(
        id: 'month_planner',
        title: 'Месячный планировщик',
        description: 'Запланируйте образы на месяц',
        icon: '🗓️',
        category: AchievementCategory.planning,
        points: 100,
        currentProgress: 0,
        targetValue: 30,
      ),
      const Achievement(
        id: 'event_planner',
        title: 'Организатор событий',
        description: 'Запланируйте 10 образов для событий',
        icon: '🎉',
        category: AchievementCategory.planning,
        points: 60,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'year_planner',
        title: 'Годовой планировщик',
        description: 'Запланируйте образы на год вперед',
        icon: '📅',
        category: AchievementCategory.planning,
        points: 200,
        currentProgress: 0,
        targetValue: 365,
      ),

      // ============================================
      // ОЦЕНКИ (Ratings) - 5 достижений
      // ============================================
      const Achievement(
        id: 'critic',
        title: 'Критик',
        description: 'Оцените 10 рекомендаций',
        icon: '📝',
        category: AchievementCategory.ratings,
        points: 30,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'positive',
        title: 'Позитивный',
        description: 'Дайте 10 оценок +8 и выше',
        icon: '👍',
        category: AchievementCategory.ratings,
        points: 50,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'honest',
        title: 'Честный',
        description: 'Дайте 5 оценок -5 и ниже',
        icon: '👎',
        category: AchievementCategory.ratings,
        points: 30,
        currentProgress: 0,
        targetValue: 5,
      ),
      const Achievement(
        id: 'rating_100',
        title: 'Активный оценщик',
        description: 'Оцените 100 рекомендаций',
        icon: '⭐',
        category: AchievementCategory.ratings,
        points: 100,
        currentProgress: 0,
        targetValue: 100,
      ),
      const Achievement(
        id: 'perfect_rating',
        title: 'Идеальная оценка',
        description: 'Дайте оценку +10 fifty раз',
        icon: '💯',
        category: AchievementCategory.ratings,
        points: 150,
        currentProgress: 0,
        targetValue: 50,
      ),

      // ============================================
      // СЕМЕЙНЫЕ (Family) - 2 достижения
      // ============================================
      const Achievement(
        id: 'family_wardrobe',
        title: 'Семейный гардероб',
        description: 'Добавьте вещи для 3 членов семьи',
        icon: '👨‍👩‍👧‍👦',
        category: AchievementCategory.family,
        points: 70,
        currentProgress: 0,
        targetValue: 3,
      ),
      const Achievement(
        id: 'family_recommendations',
        title: 'Семейные рекомендации',
        description: 'Получите 50 рекомендаций для семьи',
        icon: '👪',
        category: AchievementCategory.family,
        points: 80,
        currentProgress: 0,
        targetValue: 50,
      ),

      // ============================================
      // ПОДПИСКА (Subscription) - 3 достижения
      // ============================================
      const Achievement(
        id: 'premium_user',
        title: 'Premium пользователь',
        description: 'Оформите Premium подписку',
        icon: '💎',
        category: AchievementCategory.subscription,
        points: 100,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'pro_user',
        title: 'Pro пользователь',
        description: 'Оформите Pro подписку',
        icon: '👑',
        category: AchievementCategory.subscription,
        points: 150,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'supporter',
        title: 'Поддержавший',
        description: 'Будьте подписчиком 3 месяца подряд',
        icon: '🏆',
        category: AchievementCategory.subscription,
        points: 200,
        currentProgress: 0,
        targetValue: 3,
      ),

      // ============================================
      // ОСОБЫЕ (Special) - 7 достижений
      // ============================================
      const Achievement(
        id: 'perfectionist',
        title: 'Перфекционист',
        description: 'Соберите образ из 5+ вещей',
        icon: '✨',
        category: AchievementCategory.special,
        points: 50,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'minimalist',
        title: 'Минималист',
        description: 'Соберите образ из 2 вещей',
        icon: '🎯',
        category: AchievementCategory.special,
        points: 30,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'colorful',
        title: 'Разноцветный',
        description: 'Имейте вещи 5+ разных цветов',
        icon: '🌈',
        category: AchievementCategory.special,
        points: 60,
        currentProgress: 0,
        targetValue: 5,
      ),
      const Achievement(
        id: 'monochrome',
        title: 'Монохром',
        description: 'Соберите монохромный образ',
        icon: '⚫',
        category: AchievementCategory.special,
        points: 40,
        currentProgress: 0,
        targetValue: 1,
      ),
      const Achievement(
        id: 'brand_collector',
        title: 'Коллекционер брендов',
        description: 'Имейте вещи 10+ брендов',
        icon: '🏷️',
        category: AchievementCategory.special,
        points: 80,
        currentProgress: 0,
        targetValue: 10,
      ),
      const Achievement(
        id: 'seasonal',
        title: 'Сезонный',
        description: 'Имейте вещи для всех 4 сезонов',
        icon: '🔄',
        category: AchievementCategory.special,
        points: 70,
        currentProgress: 0,
        targetValue: 4,
      ),
      const Achievement(
        id: 'trendsetter',
        title: 'Трендовик',
        description: 'Создайте 25 уникальных образов',
        icon: '🔥',
        category: AchievementCategory.special,
        points: 100,
        currentProgress: 0,
        targetValue: 25,
      ),
    ];
  }

  /// Получить достижения по категории
  static List<Achievement> getByCategory(AchievementCategory category) {
    return getAllAchievements()
        .where((a) => a.category == category)
        .toList();
  }

  /// Получить достижение по ID
  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получить стартовые достижения
  static List<Achievement> getStarterAchievements() {
    return getByCategory(AchievementCategory.starter);
  }

  /// Получить общее количество достижений
  static int get totalAchievements => getAllAchievements().length;

  /// Получить общее количество очков
  static int get totalPoints =>
      getAllAchievements().fold(0, (sum, a) => sum + a.points);
}
