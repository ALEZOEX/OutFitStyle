import 'package:flutter/material.dart';
import '../../ui/widgets/notification_widgets.dart';

/// Экран списка уведомлений
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;
  bool showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Имитация загрузки уведомлений
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      notifications = _generateSampleNotifications();
      isLoading = false;
    });
  }

  List<NotificationModel> _generateSampleNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Прогноз погоды на завтра',
        message: 'Ожидается дождь утром и вечером. Рекомендуем взять зонт.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        type: 'weather',
      ),
      NotificationModel(
        id: '2',
        title: 'Новая рекомендация',
        message:
            'На основе вашей истории подобраны идеальные образы для сегодняшнего дня.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        type: 'recommendation',
      ),
      NotificationModel(
        id: '3',
        title: 'Обновление гардероба',
        message:
            'Добавлены новые вещи в ваш гардероб. Проверьте их в разделе "Мой гардероб".',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: false,
        type: 'wardrobe',
      ),
      NotificationModel(
        id: '4',
        title: 'Системное уведомление',
        message:
            'Приложение было обновлено до последней версии. Проверьте новые функции.',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        type: 'system',
      ),
      NotificationModel(
        id: '5',
        title: 'Важное предупреждение',
        message: 'Ожидаются заморозки ночью. Подумайте о теплой одежде.',
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
        type: 'alert',
      ),
    ];
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    setState(() {
      final index = notifications.indexOf(notification);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          isRead: true,
          type: notification.type,
        );
      }
    });
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      notifications = notifications
          .map((notification) => NotificationModel(
                id: notification.id,
                title: notification.title,
                message: notification.message,
                timestamp: notification.timestamp,
                isRead: true,
                type: notification.type,
              ))
          .toList();
    });
  }

  List<NotificationModel> get _filteredNotifications {
    if (showUnreadOnly) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.markunread_mailbox_outlined),
              onPressed: _markAllAsRead,
              tooltip: 'Отметить все как прочитанные',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              setState(() {
                showUnreadOnly = result == 'unread';
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'all',
                child: Text(
                  'Все уведомления',
                  style: TextStyle(
                    color:
                        showUnreadOnly ? theme.hintColor : theme.primaryColor,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'unread',
                child: Text(
                  'Только непрочитанные',
                  style: TextStyle(
                    color:
                        showUnreadOnly ? theme.primaryColor : theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (unreadCount > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16.0),
                  const SizedBox(width: 8.0),
                  Text(
                    '$unreadCount непрочитанных',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off,
                              size: 64.0,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              showUnreadOnly
                                  ? 'Нет непрочитанных уведомлений'
                                  : 'Уведомлений пока нет',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              showUnreadOnly
                                  ? 'Все уведомления прочитаны'
                                  : 'Здесь будут отображаться ваши уведомления',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await _loadNotifications();
                        },
                        child: ListView.builder(
                          itemCount: _filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = _filteredNotifications[index];
                            return NotificationCard(
                              notification: notification,
                              onTap: () => _markAsRead(notification),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
