import 'package:outfitstyle_client/src/features/notifications/data/models/notification_dto.dart';

/// Тестовые данные для уведомлений
class MockNotification {
  /// Создать тестовое уведомление
  static NotificationModel create({
    String id = 'test_notification',
    String title = 'Тестовое уведомление',
    String message = 'Сообщение тестового уведомления',
    DateTime? timestamp,
    bool isRead = false,
    String type = 'info',
    String? imageUrl,
    String? actionType,
    Map<String, dynamic>? actionData,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp ?? DateTime.now(),
      isRead: isRead,
      type: type,
      imageUrl: imageUrl,
      actionType: actionType,
      actionData: actionData,
    );
  }

  /// Список тестовых уведомлений
  static List<NotificationModel> createList({int count = 10}) {
    final titles = [
      'Новая рекомендация',
      'Обновление системы',
      'Напоминание',
      'Достижение разблокировано',
      'Погода изменилась',
      'Новая вещь в гардеробе',
      'Поездка скоро начнётся',
      'Отзыв о рекомендации',
      'Ежедневный вход',
      'Специальное предложение',
    ];

    final messages = [
      'Для вас подготовлена новая рекомендация наряда',
      'Приложение обновлено до последней версии',
      'Не забудьте добавить вещи для поездки',
      'Вы разблокировали новое достижение!',
      'Завтра ожидается дождь, не забудьте зонт',
      'Ваш гардероб пополнен новой вещью',
      'Ваша поездка начнётся через 3 дня',
      'Оцените последнюю рекомендацию',
      'Вы зашли 7 дней подряд!',
      'Скидка на премиум подписку',
    ];

    final types = ['info', 'success', 'warning', 'error', 'recommendation'];

    return List.generate(count, (index) => create(
      id: 'notification_$index',
      title: titles[index % titles.length],
      message: messages[index % messages.length],
      timestamp: DateTime.now().subtract(Duration(hours: index)),
      isRead: index >= 5,
      type: types[index % types.length],
    ));
  }

  /// Непрочитанное уведомление
  static NotificationModel unread() {
    return create(
      id: 'unread_notification',
      title: 'Важное уведомление',
      message: 'Это уведомление ещё не прочитано',
      isRead: false,
      type: 'info',
    );
  }

  /// Прочитанное уведомление
  static NotificationModel read() {
    return create(
      id: 'read_notification',
      title: 'Прочитанное уведомление',
      message: 'Это уведомление уже прочитано',
      isRead: true,
      type: 'success',
    );
  }

  /// Уведомление о достижении
  static NotificationModel achievement() {
    return create(
      id: 'achievement_notification',
      title: '🏆 Достижение разблокировано!',
      message: 'Вы разблокировали достижение "Мастер стиля"',
      type: 'success',
      actionType: 'achievement',
      actionData: {'achievement_id': 'style_master'},
    );
  }

  /// Уведомление о погоде
  static NotificationModel weather() {
    return create(
      id: 'weather_notification',
      title: '⛈️ Предупреждение о погоде',
      message: 'Завтра ожидается дождь. Не забудьте зонт!',
      type: 'warning',
      actionType: 'weather',
    );
  }

  /// Уведомление о поездке
  static NotificationModel trip() {
    return create(
      id: 'trip_notification',
      title: '✈️ Поездка скоро начнётся',
      message: 'Ваша поездка в Париж начнётся через 2 дня',
      type: 'info',
      actionType: 'trip',
      actionData: {'trip_id': 'trip_123'},
    );
  }

  /// Уведомление с изображением
  static NotificationModel withImage() {
    return create(
      id: 'image_notification',
      title: 'Новый образ для вас',
      message: 'Посмотрите рекомендацию от наших стилистов',
      type: 'recommendation',
      imageUrl: 'https://example.com/image.jpg',
      actionType: 'recommendation',
      actionData: {'outfit_id': 'outfit_456'},
    );
  }

  /// Старое уведомление (неделю назад)
  static NotificationModel old() {
    return create(
      id: 'old_notification',
      title: 'Старое уведомление',
      message: 'Это уведомление было создано неделю назад',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
    );
  }

  /// Недавнее уведомление (5 минут назад)
  static NotificationModel recent() {
    return create(
      id: 'recent_notification',
      title: 'Только что',
      message: 'Это очень свежее уведомление',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    );
  }
}
