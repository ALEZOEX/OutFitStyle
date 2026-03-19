import 'package:flutter/material.dart';

/// Типы уведомлений для определения иконки
enum NotificationIconType {
  weather,
  recommendation,
  wardrobe,
  system,
  alert,
  achievement,
  promo,
  unknown,
}

extension NotificationIconTypeExtension on String {
  NotificationIconType toType() {
    switch (toLowerCase()) {
      case 'weather':
      case 'weather_alert':
        return NotificationIconType.weather;
      case 'recommendation':
      case 'daily_recommendation':
        return NotificationIconType.recommendation;
      case 'wardrobe':
        return NotificationIconType.wardrobe;
      case 'system':
        return NotificationIconType.system;
      case 'alert':
      case 'warning':
        return NotificationIconType.alert;
      case 'achievement':
      case 'achievement_unlocked':
        return NotificationIconType.achievement;
      case 'promo':
      case 'marketing':
        return NotificationIconType.promo;
      default:
        return NotificationIconType.unknown;
    }
  }
}

/// Виджет иконки уведомления в зависимости от типа
class NotificationIcon extends StatelessWidget {
  final String type;
  final double size;
  final bool withBackground;

  const NotificationIcon({
    super.key,
    required this.type,
    this.size = 24.0,
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final notificationType = type.toType();
    final iconData = _getIconForType(notificationType);
    final color = _getColorForType(notificationType);

    if (!withBackground) {
      return Icon(iconData, color: color, size: size);
    }

    final iconSize = size * 0.85;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(iconData, color: color, size: iconSize),
    );
  }

  IconData _getIconForType(NotificationIconType type) {
    return switch (type) {
      NotificationIconType.weather => Icons.wb_sunny,
      NotificationIconType.recommendation => Icons.auto_awesome,
      NotificationIconType.wardrobe => Icons.checkroom,
      NotificationIconType.system => Icons.info_outline,
      NotificationIconType.alert => Icons.warning,
      NotificationIconType.achievement => Icons.emoji_events,
      NotificationIconType.promo => Icons.local_offer,
      NotificationIconType.unknown => Icons.notifications,
    };
  }

  Color _getColorForType(NotificationIconType type) {
    return switch (type) {
      NotificationIconType.weather => Colors.orange,
      NotificationIconType.recommendation => Colors.blue,
      NotificationIconType.wardrobe => Colors.green,
      NotificationIconType.system => Colors.grey,
      NotificationIconType.alert => Colors.red,
      NotificationIconType.achievement => Colors.amber,
      NotificationIconType.promo => Colors.purple,
      NotificationIconType.unknown => Colors.grey,
    };
  }
}

/// Виджет бейджа для иконки уведомлений
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final Color? backgroundColor;
  final Color? textColor;
  final double? minSize;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.backgroundColor,
    this.textColor,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Если нет непрочитанных, показываем только child
    if (count <= 0) {
      return child;
    }

    final displayCount = count > 99 ? '99+' : count.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            constraints: BoxConstraints(
              minWidth: minSize ?? 18,
              minHeight: minSize ?? 18,
            ),
            decoration: BoxDecoration(
              color: backgroundColor ?? theme.colorScheme.error,
              shape: BoxShape.circle,
              border: Border.all(color: theme.canvasColor, width: 2),
            ),
            child: Center(
              child: Text(
                displayCount,
                style: TextStyle(
                  fontSize: (minSize ?? 20) * 0.55,
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Кнопка с бейджем уведомлений для AppBar
class NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onPressed;

  const NotificationIconButton({
    super.key,
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      count: unreadCount,
      child: IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: onPressed,
        tooltip: 'Уведомления',
      ),
    );
  }
}
