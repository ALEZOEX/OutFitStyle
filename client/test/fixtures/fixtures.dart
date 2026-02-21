// Тестовые данные (fixtures) для использования в тестах
import 'package:outfitstyle_client/src/domain/entities/achievement.dart';
import 'package:outfitstyle_client/src/domain/entities/achievement_category.dart';
import 'package:outfitstyle_client/src/features/notifications/data/models/notification_dto.dart';
import 'package:outfitstyle_client/src/features/trip/domain/entities/trip.dart';

/// Фикстуры для достижений
class AchievementFixtures {
  /// Достижение по умолчанию
  static Achievement defaultAchievement = const Achievement(
    id: 'test_achievement',
    title: 'Тестовое достижение',
    description: 'Описание тестового достижения',
    icon: '🎯',
    category: AchievementCategory.starter,
    points: 10,
    currentProgress: 0,
    targetValue: 1,
    isUnlocked: false,
  );

  /// Разблокированное достижение
  static Achievement unlockedAchievement = Achievement(
    id: 'unlocked',
    title: 'Разблокировано',
    description: 'Уже разблокированное достижение',
    icon: '🏆',
    category: AchievementCategory.starter,
    points: 100,
    currentProgress: 10,
    targetValue: 10,
    isUnlocked: true,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Достижение в процессе
  static Achievement inProgressAchievement = const Achievement(
    id: 'in_progress',
    title: 'В процессе',
    description: 'Достижение в процессе выполнения',
    icon: '⏳',
    category: AchievementCategory.starter,
    points: 50,
    currentProgress: 5,
    targetValue: 10,
    isUnlocked: false,
  );

  /// Список достижений для тестов
  static List<Achievement> get achievementsList => [
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
        const Achievement(
          id: 'critic',
          title: 'Критик',
          description: 'Оценить 50 рекомендаций',
          icon: '⭐',
          category: AchievementCategory.ratings,
          points: 50,
          currentProgress: 25,
          targetValue: 50,
          isUnlocked: false,
        ),
      ];
}

/// Фикстуры для уведомлений
class NotificationFixtures {
  /// Уведомление по умолчанию
  static NotificationModel defaultNotification = NotificationModel(
    id: 'test_notification',
    title: 'Тестовое уведомление',
    message: 'Сообщение тестового уведомления',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    isRead: false,
    type: 'info',
  );

  /// Непрочитанное уведомление
  static NotificationModel unreadNotification = NotificationModel(
    id: 'unread',
    title: 'Важное уведомление',
    message: 'Это уведомление ещё не прочитано',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    isRead: false,
    type: 'info',
  );

  /// Прочитанное уведомление
  static NotificationModel readNotification = NotificationModel(
    id: 'read',
    title: 'Прочитанное уведомление',
    message: 'Это уведомление уже прочитано',
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    isRead: true,
    type: 'success',
  );

  /// Список уведомлений для тестов
  static List<NotificationModel> get notificationsList => [
        NotificationModel(
          id: 'notif_1',
          title: 'Новая рекомендация',
          message: 'Для вас подготовлена новая рекомендация наряда',
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          isRead: false,
          type: 'recommendation',
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Достижение разблокировано',
          message: 'Вы разблокировали новое достижение!',
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          isRead: false,
          type: 'success',
        ),
        NotificationModel(
          id: 'notif_3',
          title: 'Старое уведомление',
          message: 'Это уведомление уже прочитано',
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          isRead: true,
          type: 'info',
        ),
      ];
}

/// Фикстуры для поездок
class TripFixtures {
  /// Поездка по умолчанию
  static Trip defaultTrip = Trip(
    id: 'test_trip',
    userId: 'test_user',
    name: 'Тестовая поездка',
    destination: 'Париж, Франция',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    endDate: DateTime.fromMillisecondsSinceEpoch(0),
    occasions: const ['casual'],
    packingList: const [],
    status: TripStatus.planned,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Активная поездка
  static Trip activeTrip = Trip(
    id: 'active_trip',
    userId: 'test_user',
    name: 'Активная поездка',
    destination: 'Париж, Франция',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    endDate: DateTime.fromMillisecondsSinceEpoch(0),
    occasions: const ['casual', 'sightseeing'],
    packingList: const [
      TripPackingItem(
        id: 'item_1',
        wardrobeItemId: 'wardrobe_1',
        name: 'Джинсы',
        category: 'bottoms',
        isPacked: true,
        isRecommended: true,
      ),
    ],
    status: TripStatus.active,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    weather: TripWeather(
      temperature: 18,
      condition: 'Cloudy',
      feelsLike: 17,
      humidity: 65,
      windSpeed: 3,
      iconUrl: '04d',
    ),
  );

  /// Запланированная поездка
  static Trip plannedTrip = Trip(
    id: 'planned_trip',
    userId: 'test_user',
    name: 'Запланированная поездка',
    destination: 'Лондон, Великобритания',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    endDate: DateTime.fromMillisecondsSinceEpoch(0),
    occasions: const ['business'],
    packingList: const [],
    status: TripStatus.planned,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Завершённая поездка
  static Trip completedTrip = Trip(
    id: 'completed_trip',
    userId: 'test_user',
    name: 'Завершённая поездка',
    destination: 'Рим, Италия',
    startDate: DateTime.fromMillisecondsSinceEpoch(0),
    endDate: DateTime.fromMillisecondsSinceEpoch(0),
    occasions: const ['sightseeing'],
    packingList: const [],
    status: TripStatus.completed,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Список поездок для тестов
  static List<Trip> get tripsList => [
        activeTrip,
        plannedTrip,
        completedTrip,
      ];
}

/// Фикстуры для категорий достижений
class CategoryFixtures {
  static const allCategories = AchievementCategory.values;

  static const wardrobeCategory = AchievementCategory.wardrobe;
  static const ratingsCategory = AchievementCategory.ratings;
  static const planningCategory = AchievementCategory.planning;
  static const starterCategory = AchievementCategory.starter;
}
