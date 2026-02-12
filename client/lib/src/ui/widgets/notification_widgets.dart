import 'package:flutter/material.dart';

/// Модель уведомления
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'info',
  });
}

/// Виджет карточки уведомления
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: isUnread ? 4.0 : 2.0,
      color: isUnread
          ? theme.cardTheme.color?.withOpacity(0.9)
          : theme.cardTheme.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка уведомления в зависимости от типа
              _buildNotificationIcon(notification.type, theme),

              const SizedBox(width: 12.0),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isUnread
                                  ? theme.primaryColor
                                  : theme.textTheme.titleMedium?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _formatTime(notification.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUnread
                            ? theme.textTheme.bodyLarge?.color
                            : theme.hintColor,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (!isUnread) ...[
                const SizedBox(width: 8.0),
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, ThemeData theme) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'weather':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'recommendation':
        icon = Icons.auto_awesome;
        color = Colors.blue;
        break;
      case 'wardrobe':
        icon = Icons.checkroom;
        color = Colors.green;
        break;
      case 'system':
        icon = Icons.info;
        color = Colors.grey;
        break;
      case 'alert':
        icon = Icons.warning;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20.0,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes мин. назад';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ч. назад';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days дн. назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }
}

/// Виджет бейджа уведомлений
class NotificationBadgeWidget extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final bool showZero;

  const NotificationBadgeWidget({
    Key? key,
    required this.count,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (count <= 0 && !showZero) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -5,
          right: -5,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.canvasColor,
                width: 2.0,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: size ?? 20.0,
              minHeight: size ?? 20.0,
            ),
            child: Text(
              count > 99 ? '99+' : count.toString(),
              style: TextStyle(
                fontSize: size != null ? size! * 0.5 : 10.0,
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
