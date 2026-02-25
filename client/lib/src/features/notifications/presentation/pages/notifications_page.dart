import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/widgets/max_width_container.dart';
import '../../data/models/notification_dto.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_tile.dart';

/// Страница уведомлений
/// Показывает список уведомлений с группировкой по статусу прочтения
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    // Загружаем уведомления при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    // Не останавливаем polling здесь, т.к. он управляется на уровне приложения
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    // Фильтруем уведомления
    final displayedNotifications =
        _showUnreadOnly ? state.unreadNotifications : state.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        actions: [
          // Кнопка "Прочитать все"
          if (state.unreadCount > 0 && !_showUnreadOnly)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: () => _showConfirmMarkAllAsRead(notifier),
              tooltip: 'Прочитать все',
            ),
          // Фильтр
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Фильтр',
            onSelected: (value) {
              setState(() {
                _showUnreadOnly = value;
              });
            },
            itemBuilder:
                (context) => [
                  CheckedPopupMenuItem(
                    value: false,
                    checked: !_showUnreadOnly,
                    child: const Text('Все уведомления'),
                  ),
                  CheckedPopupMenuItem(
                    value: true,
                    checked: _showUnreadOnly,
                    child: const Text('Только непрочитанные'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Индикатор непрочитанных
          if (state.unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Непрочитанных: ${state.unreadCount}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Основной контент
          Expanded(
            child: ResponsiveMaxWidthContainer(
              child: _buildContent(state, displayedNotifications, notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    NotificationsState state,
    List<NotificationModel> notifications,
    NotificationsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    // Загрузка
    if (state.status == NotificationsLoadStatus.loading &&
        notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ошибка
    if (state.status == NotificationsLoadStatus.error &&
        notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'Неизвестная ошибка',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => notifier.loadNotifications(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    // Пустой список
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _showUnreadOnly
                  ? Icons.check_circle_outline
                  : Icons.notifications_none,
              size: 64,
              color: theme.hintColor,
            ),
            const SizedBox(height: 16),
            Text(
              _showUnreadOnly
                  ? 'Нет непрочитанных уведомлений'
                  : 'Уведомлений пока нет',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _showUnreadOnly
                  ? 'Все уведомления прочитаны'
                  : 'Здесь будут отображаться ваши уведомления',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Список с группировкой
    return RefreshIndicator(
      onRefresh: () async {
        await notifier.loadNotifications(refresh: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Показываем индикатор загрузки внизу если есть ещё данные
          if (state.hasMore && index == notifications.length) {
            if (state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          }

          final notification = notifications[index];

          // Показываем заголовки секций
          if (index == 0 &&
              !_showUnreadOnly &&
              state.readNotifications.isNotEmpty) {
            // Показываем заголовок "Непрочитанные" если есть непрочитанные
            if (notification.isRead == false) {
              return Column(
                children: [
                  NotificationSectionHeader(
                    title: 'Непрочитанные',
                    count: state.unreadCount,
                    onMarkAllRead: () => _showConfirmMarkAllAsRead(notifier),
                    showMarkAllRead: state.unreadCount > 1,
                  ),
                  NotificationTile(
                    notification: notification,
                    onTap: () => _handleNotificationTap(notification, notifier),
                  ),
                ],
              );
            }
          }

          // Показываем заголовок "Прочитанные" при переходе
          if (index > 0 &&
              !_showUnreadOnly &&
              notifications[index - 1].isRead == false &&
              notification.isRead) {
            return Column(
              children: [
                NotificationSectionHeader(
                  title: 'Прочитанные',
                  count: state.readNotifications.length,
                ),
                NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification, notifier),
                ),
              ],
            );
          }

          return NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification, notifier),
          );
        },
      ),
    );
  }

  /// Обработка тапа по уведомлению
  void _handleNotificationTap(
    NotificationModel notification,
    NotificationsNotifier notifier,
  ) {
    // Отмечаем как прочитанное
    if (!notification.isRead) {
      notifier.markAsRead(notification.id);
    }

    // Здесь можно добавить навигацию по actionType
    // switch (notification.actionType) { ... }
  }

  /// Показать подтверждение для "Прочитать все"
  void _showConfirmMarkAllAsRead(NotificationsNotifier notifier) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Прочитать все'),
            content: const Text(
              'Вы уверены, что хотите отметить все уведомления как прочитанные?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  notifier.markAllAsRead();
                },
                child: const Text('Прочитать все'),
              ),
            ],
          ),
    );
  }
}
