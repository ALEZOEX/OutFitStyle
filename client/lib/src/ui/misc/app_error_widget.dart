import 'package:flutter/material.dart';

/// Custom error widget
class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? details;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onRetry;
  final ErrorVariant variant;
  final EdgeInsets padding;

  const AppErrorWidget({
    Key? key,
    required this.message,
    this.details,
    this.icon,
    this.buttonText,
    this.onRetry,
    this.variant = ErrorVariant.generic,
    this.padding = const EdgeInsets.all(24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData displayIcon;
    String displayButtonText = buttonText ?? 'Повторить';

    switch (variant) {
      case ErrorVariant.network:
        displayIcon = icon ?? Icons.signal_wifi_off_outlined;
        displayButtonText = buttonText ?? 'Повторить';
        break;
      case ErrorVariant.server:
        displayIcon = icon ?? Icons.cloud_off_outlined;
        displayButtonText = buttonText ?? 'Обновить';
        break;
      case ErrorVariant.permission:
        displayIcon = icon ?? Icons.block_outlined;
        displayButtonText = buttonText ?? 'Настройки';
        break;
      case ErrorVariant.notFound:
        displayIcon = icon ?? Icons.error_outline;
        displayButtonText = buttonText ?? 'Вернуться назад';
        break;
      case ErrorVariant.authentication:
        displayIcon = icon ?? Icons.lock_outlined;
        displayButtonText = buttonText ?? 'Войти снова';
        break;
      case ErrorVariant.generic:
        displayIcon = icon ?? Icons.error_outline;
        break;
    }

    return Padding(
      padding: padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              displayIcon,
              size: 64.0,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24.0),
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 8.0),
              Text(
                details!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              SizedBox(
                width: 200.0,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(displayButtonText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Specialized error widget for weather data
class WeatherDataErrorWidget extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRetry;

  const WeatherDataErrorWidget({
    Key? key,
    this.customMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: customMessage ?? 'Ошибка получения погоды',
      details:
          'Не удалось получить актуальные данные о погоде. Проверьте подключение к интернету.',
      icon: Icons.cloud_off_outlined,
      buttonText: 'Повторить',
      onRetry: onRetry,
      variant: ErrorVariant.network,
    );
  }
}

enum ErrorVariant {
  network,
  server,
  permission,
  notFound,
  authentication,
  generic
}
