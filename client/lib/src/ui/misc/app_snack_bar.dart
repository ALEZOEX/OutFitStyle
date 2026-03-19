import 'package:flutter/material.dart';

/// Custom snackbar widget
class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarVariant variant = SnackBarVariant.info,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData displayIcon;

    switch (variant) {
      case SnackBarVariant.success:
        backgroundColor = theme.colorScheme.primary;
        textColor = Colors.white;
        displayIcon = icon ?? Icons.check_circle_outline;
        break;
      case SnackBarVariant.error:
        backgroundColor = theme.colorScheme.error;
        textColor = Colors.white;
        displayIcon = icon ?? Icons.error_outline;
        break;
      case SnackBarVariant.warning:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        displayIcon = icon ?? Icons.warning_amber_outlined;
        break;
      case SnackBarVariant.info:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        displayIcon = icon ?? Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(displayIcon, color: textColor),
          const SizedBox(width: 12.0),
          Expanded(child: Text(message, style: TextStyle(color: textColor))),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action:
          actionLabel != null && onAction != null
              ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
                textColor: textColor,
              )
              : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a simple success message
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      variant: SnackBarVariant.success,
      duration: duration,
    );
  }

  /// Show a simple error message
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      variant: SnackBarVariant.error,
      duration: duration,
    );
  }

  /// Show a simple warning message
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      variant: SnackBarVariant.warning,
      duration: duration,
    );
  }

  /// Show a simple info message
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      variant: SnackBarVariant.info,
      duration: duration,
    );
  }
}

/// Specialized snack bar for outfit actions
class OutfitSnackBar {
  static void showAddedToFavorites(BuildContext context) {
    AppSnackBar.showSuccess(
      context,
      'Добавлено в избранное',
      duration: const Duration(seconds: 2),
    );
  }

  static void showRemovedFromFavorites(BuildContext context) {
    AppSnackBar.showInfo(
      context,
      'Удалено из избранного',
      duration: const Duration(seconds: 2),
    );
  }

  static void showWeatherUpdated(BuildContext context) {
    AppSnackBar.showInfo(
      context,
      'Данные о погоде обновлены',
      duration: const Duration(seconds: 2),
    );
  }

  static void showRecommendationSaved(BuildContext context) {
    AppSnackBar.showSuccess(
      context,
      'Рекомендация сохранена',
      duration: const Duration(seconds: 2),
    );
  }
}

enum SnackBarVariant { success, error, warning, info }
