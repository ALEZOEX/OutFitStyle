import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для работы с уведомлениями
///
/// Обрабатывает:
/// - Получение push-уведомлений от Firebase
/// - Отображение локальных уведомлений
/// - Управление токенами устройств
/// - Проверку настроек уведомлений пользователя
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Ключи для хранения настроек в SharedPreferences
  static const String _pushEnabledKey = 'push_enabled';
  static const String _weatherAlertsKey = 'weather_alerts';
  static const String _recommendationReadyKey = 'recommendation_ready';
  static const String _newArrivalsKey = 'new_arrivals';
  static const String _achievementUnlockedKey = 'achievement_unlocked';
  static const String _promotionalKey = 'promotional';
  static const String _tripUpdatesKey = 'trip_updates';
  static const String _outfitRemindersKey = 'outfit_reminders';

  /// Инициализация сервиса уведомлений
  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configure local notifications for Android
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotifications.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Handle terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Показать локальное уведомление
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        0,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'outfitstyle_channel',
            'OutfitStyle Notifications',
            importance: Importance.max,
          ),
        ),
      );
    }
  }

  /// Обработать тап по уведомлению
  void _handleNotificationTap(RemoteMessage message) {
    // Handle notification tap - navigate to appropriate screen
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'daily_recommendation':
        // Navigate to recommendations screen
        break;
      case 'weather_alert':
        // Navigate to weather screen
        break;
      case 're_engagement':
        // Navigate to home screen
        break;
    }
  }

  /// Получить токен устройства
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Подписаться на топик
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Отписаться от топика
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Проверить, включены ли Push-уведомления глобально
  Future<bool> isPushEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_pushEnabledKey) ?? true;
    } catch (e) {
      return true; // По умолчанию включено
    }
  }

  /// Проверить настройку конкретного типа уведомления
  Future<bool> _isNotificationTypeEnabled(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Сначала проверяем глобальный флаг
      final pushEnabled = prefs.getBool(_pushEnabledKey) ?? true;
      if (!pushEnabled) return false;

      // Затем проверяем конкретный тип
      return prefs.getBool(key) ?? true;
    } catch (e) {
      return true; // По умолчанию включено
    }
  }

  /// Можно ли показывать уведомления о погоде
  Future<bool> canShowWeatherAlerts() async {
    return _isNotificationTypeEnabled(_weatherAlertsKey);
  }

  /// Можно ли показывать уведомления о рекомендациях
  Future<bool> canShowRecommendations() async {
    return _isNotificationTypeEnabled(_recommendationReadyKey);
  }

  /// Можно ли показывать уведомления о новых поступлениях
  Future<bool> canShowNewArrivals() async {
    return _isNotificationTypeEnabled(_newArrivalsKey);
  }

  /// Можно ли показывать уведомления о достижениях
  Future<bool> canShowAchievements() async {
    return _isNotificationTypeEnabled(_achievementUnlockedKey);
  }

  /// Можно ли показывать промо-уведомления
  Future<bool> canShowPromotional() async {
    return _isNotificationTypeEnabled(_promotionalKey);
  }

  /// Можно ли показывать уведомления о поездках
  Future<bool> canShowTripUpdates() async {
    return _isNotificationTypeEnabled(_tripUpdatesKey);
  }

  /// Можно ли показывать напоминания о outfits
  Future<bool> canShowOutfitReminders() async {
    return _isNotificationTypeEnabled(_outfitRemindersKey);
  }

  /// Показать уведомление только если разрешено пользователем
  ///
  /// [type] - тип уведомления (должен соответствовать ключам настроек)
  /// [title] - заголовок уведомления
  /// [body] - текст уведомления
  /// [data] - дополнительные данные
  Future<void> showNotificationIfAllowed({
    required String type,
    required String? title,
    required String? body,
    Map<String, dynamic>? data,
  }) async {
    // Проверяем глобальный флаг
    final isPushEnabled = await this.isPushEnabled();
    if (!isPushEnabled) return;

    // Проверяем тип уведомления
    bool isAllowed = true;
    switch (type) {
      case 'weather_alert':
        isAllowed = await canShowWeatherAlerts();
        break;
      case 'daily_recommendation':
      case 'recommendation_ready':
        isAllowed = await canShowRecommendations();
        break;
      case 'new_arrival':
        isAllowed = await canShowNewArrivals();
        break;
      case 'achievement':
        isAllowed = await canShowAchievements();
        break;
      case 'promotional':
        isAllowed = await canShowPromotional();
        break;
      case 'trip_update':
        isAllowed = await canShowTripUpdates();
        break;
      case 'outfit_reminder':
        isAllowed = await canShowOutfitReminders();
        break;
      default:
        // Для неизвестных типов проверяем только глобальный флаг
        break;
    }

    if (!isAllowed) return;

    // Показываем уведомление
    if (title != null || body != null) {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title ?? 'OutfitStyle',
        body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'outfitstyle_channel',
            'OutfitStyle Notifications',
            importance: Importance.max,
          ),
        ),
        payload: data != null ? _encodePayload(data) : null,
      );
    }
  }

  /// Закодировать payload для уведомления
  String _encodePayload(Map<String, dynamic> data) {
    // Простая сериализация - можно улучшить с использованием jsonEncode
    return data.toString();
  }

  /// Запросить разрешение на уведомления
  Future<bool> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Проверить статус разрешения
  Future<bool> hasPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
