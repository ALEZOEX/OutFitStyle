import 'package:flutter/material.dart';

/// Custom empty state widget
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onActionPressed;
  final EmptyStateVariant variant;
  final Widget? customImage;
  final EdgeInsets padding;

  const AppEmptyState({
    Key? key,
    required this.title,
    this.message,
    this.icon,
    this.buttonText,
    this.onActionPressed,
    this.variant = EmptyStateVariant.generic,
    this.customImage,
    this.padding = const EdgeInsets.all(24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData displayIcon;
    String displayTitle = title;
    String? displayMessage = message;

    switch (variant) {
      case EmptyStateVariant.noData:
        displayIcon = icon ?? Icons.data_usage_outlined;
        displayTitle = title.isEmpty ? 'Нет данных' : title;
        displayMessage = message ?? 'Пока нет доступных данных для отображения';
        break;
      case EmptyStateVariant.search:
        displayIcon = icon ?? Icons.search_outlined;
        displayTitle = title.isEmpty ? 'Ничего не найдено' : title;
        displayMessage = message ?? 'Попробуйте изменить параметры поиска';
        break;
      case EmptyStateVariant.error:
        displayIcon = icon ?? Icons.error_outline;
        displayTitle = title.isEmpty ? 'Произошла ошибка' : title;
        displayMessage =
            message ?? 'Не удалось загрузить данные. Попробуйте еще раз.';
        break;
      case EmptyStateVariant.empty:
        displayIcon = icon ?? Icons.inbox_outlined;
        displayTitle = title.isEmpty ? 'Пусто' : title;
        displayMessage = message ?? 'Здесь пока ничего нет';
        break;
      case EmptyStateVariant.connection:
        displayIcon = icon ?? Icons.signal_wifi_off_outlined;
        displayTitle = title.isEmpty ? 'Нет подключения' : title;
        displayMessage = message ?? 'Проверьте подключение к интернету';
        break;
      case EmptyStateVariant.generic:
        displayIcon = icon ?? Icons.info_outline;
        break;
    }

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customImage != null) ...[
              customImage!,
              const SizedBox(height: 24.0),
            ] else ...[
              Icon(
                displayIcon,
                size: 64.0,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 24.0),
            ],
            Text(
              displayTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (displayMessage != null) ...[
              const SizedBox(height: 8.0),
              Text(
                displayMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onActionPressed != null) ...[
              const SizedBox(height: 24.0),
              SizedBox(
                width: 200.0,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  child: Text(buttonText!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized empty state for outfit recommendations
class OutfitRecommendationsEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const OutfitRecommendationsEmptyState({
    Key? key,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Нет рекомендаций',
      message:
          'На основе вашей локации и предпочтений пока не сформированы рекомендации',
      icon: Icons.local_cafe_outlined,
      buttonText: 'Обновить',
      onActionPressed: onRefresh,
      variant: EmptyStateVariant.generic,
    );
  }
}

enum EmptyStateVariant { noData, search, error, empty, connection, generic }
