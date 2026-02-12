import 'package:flutter/material.dart';

/// Custom badge widget
class AppBadge extends StatelessWidget {
  final Widget child;
  final String? text;
  final Widget? icon;
  final BadgeVariant variant;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final double size;
  final bool showBadge;

  const AppBadge({
    Key? key,
    required this.child,
    this.text,
    this.icon,
    this.variant = BadgeVariant.notification,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
    this.size = 18.0,
    this.showBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showBadge) {
      return child;
    }

    final theme = Theme.of(context);

    Color badgeColor;
    Color badgeTextColor;

    switch (variant) {
      case BadgeVariant.notification:
        badgeColor = backgroundColor ?? theme.colorScheme.error;
        badgeTextColor = textColor ?? Colors.white;
        break;
      case BadgeVariant.success:
        badgeColor = backgroundColor ?? theme.colorScheme.primary;
        badgeTextColor = textColor ?? Colors.white;
        break;
      case BadgeVariant.warning:
        badgeColor = backgroundColor ?? Colors.orange;
        badgeTextColor = textColor ?? Colors.white;
        break;
      case BadgeVariant.info:
        badgeColor = backgroundColor ?? Colors.blue;
        badgeTextColor = textColor ?? Colors.white;
        break;
      case BadgeVariant.custom:
        badgeColor = backgroundColor ?? theme.primaryColor;
        badgeTextColor = textColor ?? Colors.white;
        break;
    }

    Widget badgeContent = text != null
        ? Text(
            text!,
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              color: badgeTextColor,
            ),
          )
        : icon ??
            const Icon(
              Icons.circle,
              size: 8.0,
              color: Colors.white,
            );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -size / 4,
          right: -size / 4,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            child: Center(
              child: badgeContent,
            ),
          ),
        ),
      ],
    );
  }
}

/// Specialized badge for weather conditions
class WeatherConditionBadge extends StatelessWidget {
  final String condition;
  final IconData icon;
  final Color color;

  const WeatherConditionBadge({
    Key? key,
    required this.condition,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20.0,
        ),
      ),
      text: condition,
      variant: BadgeVariant.custom,
      backgroundColor: color,
      showBadge: true,
    );
  }
}

enum BadgeVariant { notification, success, warning, info, custom }
