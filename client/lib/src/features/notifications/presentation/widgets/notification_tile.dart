import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/notification_dto.dart';
import 'notification_icon.dart';

/// Виджет плитки уведомления
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isUnread ? 2 : 0,
      color:
          isUnread
              ? theme.colorScheme.surfaceContainerHighest
              : theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isUnread
                ? BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                )
                : BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка уведомления
              NotificationIcon(type: notification.type, size: 40),

              const SizedBox(width: 12),

              // Контент
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и время
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isUnread
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                              color:
                                  isUnread
                                      ? theme.colorScheme.onSurface
                                      : theme.textTheme.titleMedium?.color
                                          ?.withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Время
                        Flexible(
                          child: Text(
                            _formatTimestamp(notification.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Сообщение
                    if (notification.message.isNotEmpty)
                      Text(
                        notification.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              isUnread
                                  ? theme.textTheme.bodyLarge?.color
                                  : theme.hintColor,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Индикатор непрочитанного
              if (!isUnread) ...[
                const SizedBox(width: 8),
                // Пустой индикатор для прочитанных
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 8),
                // Синяя точка для непрочитанных
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Форматирование времени
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    // Сегодня
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 1) {
          return 'Только что';
        } else if (difference.inMinutes < 60) {
          return '${difference.inMinutes} мин. назад';
        } else {
          return '${difference.inHours} ч. назад';
        }
      } else {
        // Показываем время для событий сегодня
        return DateFormat('HH:mm').format(dateTime);
      }
    }

    // Вчера
    if (difference.inDays == 1) {
      return 'Вчера';
    }

    // Эта неделя
    if (difference.inDays < 7) {
      const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return weekdays[dateTime.weekday - 1];
    }

    // Старше недели - показываем дату
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }
}

/// Виджет заголовка секции уведомлений
class NotificationSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final VoidCallback? onMarkAllRead;
  final bool showMarkAllRead;

  const NotificationSectionHeader({
    super.key,
    required this.title,
    required this.count,
    this.onMarkAllRead,
    this.showMarkAllRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (showMarkAllRead && onMarkAllRead != null)
            TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Все проч.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
