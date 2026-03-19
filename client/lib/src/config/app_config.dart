import 'package:flutter/foundation.dart';

class AppConfig {
  // Основные настройки приложения
  static const String appName = 'OutfitStyle';
  static const String version = '1.0.0';

  // Базовые URL для API
  // Для production: '' — запросы будут относительными (/api/v1/...), nginx проксирует на бэкенд
  // Для development: 'http://localhost:8080'
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDebugMode ? 'http://localhost:8080' : '',
  );

  // Настройки Firebase
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'outfitstyle-dev',
  );
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );

  // Настройки ML сервиса
  static const String mlServiceUrl = String.fromEnvironment(
    'ML_SERVICE_URL',
    defaultValue:
        kDebugMode ? 'http://localhost:8000' : 'https://ml.outfitstyle.com',
  );

  // Настройки погодного API
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );

  // Настройки безопасности
  static const Duration sessionTimeout = Duration(hours: 24);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Настройки кэширования
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration longCacheExpiry = Duration(days: 7);

  // Настройки UI
  static const bool enableAnimations = true;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;

  // Фичефлаги
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
}
