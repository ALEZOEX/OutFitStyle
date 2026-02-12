import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../../ui/widgets/notification_widgets.dart';
import '../../../../domain/entities/achievement.dart';

// Провайдер для уведомлений об ачивках
final achievementNotificationProvider =
    Provider((ref) => AchievementNotificationService());

class AchievementNotificationService {
  AchievementNotificationService() {
    tz_data.initializeTimeZones(); // Инициализация часовых поясов
  }

  // Отправить уведомление о разблокировке ачивки
  void sendAchievementUnlockedNotification(
      String userId, Achievement achievement) {
    // В реальной реализации здесь будет вызов push-уведомлений
    // или добавление в очередь уведомлений для показа в интерфейсе

    debugPrint(
        'Отправка уведомления о разблокировке ачивки: ${achievement.title}');

    // Создаем уведомление
    final notification = NotificationModel(
      id: 'achievement_${achievement.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Новое достижение!',
      message:
          'Вы разблокировали "${achievement.title}": ${achievement.description}',
      timestamp: DateTime.now(),
      isRead: false,
      type: 'achievement',
    );

    // Здесь можно добавить уведомление в хранилище уведомлений
    _addToNotificationHistory(notification);
  }

  // Внутренний метод для добавления уведомления в историю
  void _addToNotificationHistory(NotificationModel notification) {
    // В реальной реализации здесь будет сохранение в локальное хранилище или отправка на сервер
    debugPrint('Уведомление добавлено в историю: ${notification.title}');
  }

  // Показать всплывающее уведомление о разблокировке ачивки
  void showInAppAchievementNotification(
    BuildContext context,
    Achievement achievement,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Поздравляем!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'Вы разблокировали достижение: ${achievement.title}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Смотреть',
          textColor: Colors.white,
          onPressed: () {
            // В реальном приложении здесь может быть навигация к экрану ачивок
          },
        ),
      ),
    );
  }
}
