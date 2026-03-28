import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification type enum
enum NotificationType {
  weatherChange('weather_change'),
  outfitRecommendation('outfit_recommendation'),
  system('system');

  const NotificationType(this.value);
  final String value;
}

/// Notification priority enum
enum NotificationPriority {
  low(0),
  normal(1),
  high(2),
  max(3);

  const NotificationPriority(this.priority);
  final int priority;
}

/// Notification data class
class NotificationData {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;
  final bool read;

  NotificationData({
    String? id,
    required this.title,
    required this.body,
    required this.type,
    DateTime? timestamp,
    this.payload,
    this.read = false,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (element) => element.value == json['type'],
        orElse: () => NotificationType.system,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      payload:
          json['payload'] != null
              ? Map<String, dynamic>.from(json['payload'])
              : null,
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.value,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
      'read': read,
    };
  }

  NotificationData copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    Map<String, dynamic>? payload,
    bool? read,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      payload: payload ?? this.payload,
      read: read ?? this.read,
    );
  }
}

/// Notification settings class
class NotificationSettings {
  final bool enableLocalNotifications;
  final bool enablePushNotifications;
  final bool enableWeatherAlerts;
  final bool enableOutfitRecommendations;
  final TimeOfDay? dailyRecommendationTime;
  final double temperatureThreshold; // Temperature threshold for alerts

  NotificationSettings({
    this.enableLocalNotifications = true,
    this.enablePushNotifications = true,
    this.enableWeatherAlerts = true,
    this.enableOutfitRecommendations = true,
    this.dailyRecommendationTime,
    this.temperatureThreshold = 5.0, // Default 5°C threshold
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enableLocalNotifications: json['enableLocalNotifications'] ?? true,
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enableWeatherAlerts: json['enableWeatherAlerts'] ?? true,
      enableOutfitRecommendations: json['enableOutfitRecommendations'] ?? true,
      dailyRecommendationTime:
          json['dailyRecommendationTime'] != null
              ? _parseTimeOfDay(json['dailyRecommendationTime'])
              : null,
      temperatureThreshold:
          (json['temperatureThreshold'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    final timeString =
        dailyRecommendationTime != null
            ? '${dailyRecommendationTime!.hour}:${dailyRecommendationTime!.minute.toString().padLeft(2, '0')}'
            : null;

    return {
      'enableLocalNotifications': enableLocalNotifications,
      'enablePushNotifications': enablePushNotifications,
      'enableWeatherAlerts': enableWeatherAlerts,
      'enableOutfitRecommendations': enableOutfitRecommendations,
      'dailyRecommendationTime': timeString,
      'temperatureThreshold': temperatureThreshold,
    };
  }

  NotificationSettings copyWith({
    bool? enableLocalNotifications,
    bool? enablePushNotifications,
    bool? enableWeatherAlerts,
    bool? enableOutfitRecommendations,
    TimeOfDay? dailyRecommendationTime,
    double? temperatureThreshold,
  }) {
    return NotificationSettings(
      enableLocalNotifications:
          enableLocalNotifications ?? this.enableLocalNotifications,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableWeatherAlerts: enableWeatherAlerts ?? this.enableWeatherAlerts,
      enableOutfitRecommendations:
          enableOutfitRecommendations ?? this.enableOutfitRecommendations,
      dailyRecommendationTime:
          dailyRecommendationTime ?? this.dailyRecommendationTime,
      temperatureThreshold: temperatureThreshold ?? this.temperatureThreshold,
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }
}

/// Abstract notification service class
abstract class NotificationService extends ChangeNotifier {
  /// Initialize the notification service
  Future<void> initialize();

  /// Send local notification
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? payload,
  });

  /// Schedule daily recommendation notification
  Future<void> scheduleDailyRecommendationNotification(TimeOfDay time);

  /// Cancel scheduled notification
  Future<void> cancelScheduledNotification(int id);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Clear all notifications
  Future<void> clearAllNotifications();

  /// Get unread count
  int getUnreadCount();

  /// Get notifications by type
  List<NotificationData> getNotificationsByType(NotificationType type);

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Get FCM token
  Future<String?> getFcmToken();

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Update notification settings
  Future<void> updateSettings(NotificationSettings newSettings);

  /// Get current notification settings
  NotificationSettings get settings;

  /// Get list of notifications
  List<NotificationData> get notifications;
}

/// Firebase implementation of notification service
class FirebaseNotificationService extends NotificationService {
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late FirebaseMessaging _firebaseMessaging;
  List<NotificationData> _notifications = [];
  NotificationSettings _settings = NotificationSettings();

  @override
  List<NotificationData> get notifications => _notifications;

  @override
  NotificationSettings get settings => _settings;

  @override
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializePushNotifications();
    await _loadSettings();
    await _loadNotifications();
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// Initialize push notifications
  Future<void> _initializePushNotifications() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token
    final token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.notification?.title ?? ''}');

      if (_settings.enablePushNotifications) {
        _processPushNotification(message);
      }
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'Background message opened app: ${message.notification?.title ?? ''}',
      );
      _navigateToNotification(message);
    });
  }

  /// Process incoming push notification
  void _processPushNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final notificationType = _getNotificationTypeFromData(message.data);

      final notificationData = NotificationData(
        title: notification.title ?? 'Новое уведомление',
        body: notification.body ?? '',
        type: notificationType,
        payload: message.data,
      );

      _addNotification(notificationData);
      _showLocalNotification(notificationData);
    }
  }

  /// Get notification type from message data
  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    final typeStr = data['type'] as String?;
    switch (typeStr) {
      case 'weather_change':
        return NotificationType.weatherChange;
      case 'outfit_recommendation':
        return NotificationType.outfitRecommendation;
      default:
        return NotificationType.system;
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationData notification) async {
    if (!_settings.enableLocalNotifications) return;

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'outfitstyle_channel',
      'OutfitStyle Notifications',
      channelDescription: 'Уведомления о погоде и рекомендациях нарядов',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
    );

    const iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      notification.id.hashCode % 1000000, // Ensure ID is within range
      notification.title,
      notification.body,
      platformChannelSpecifics,
      payload: jsonEncode(notification.toJson()),
    );
  }

  /// Handle notification selection
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      try {
        final notificationJson = jsonDecode(response.payload!);
        final notification = NotificationData.fromJson(notificationJson);

        // Mark as read
        await markAsRead(notification.id);

        // Navigate to appropriate screen based on notification type
        _navigateToNotificationByType(notification);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Navigate to appropriate screen based on notification type
  void _navigateToNotificationByType(NotificationData notification) {
    // This would typically navigate to the appropriate screen
    // For now, we'll just log the action
    debugPrint(
      'Navigating to screen for notification type: ${notification.type}',
    );
  }

  /// Navigate to notification from push message
  void _navigateToNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final notificationType = _getNotificationTypeFromData(message.data);
      final notificationData = NotificationData(
        title: notification.title ?? 'Новое уведомление',
        body: notification.body ?? '',
        type: notificationType,
        payload: message.data,
      );

      _navigateToNotificationByType(notificationData);
    }
  }

  /// Add notification to local storage
  Future<void> _addNotification(NotificationData notification) async {
    _notifications.insert(0, notification);
    notifyListeners();
    await _saveNotifications();
  }

  /// Save notifications to shared preferences
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications.map((n) => n.toJson()).toList();
    await prefs.setStringList(
      'notifications',
      notificationsJson.map((e) => jsonEncode(e)).toList(),
    );
  }

  /// Load notifications from shared preferences
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications') ?? [];

    _notifications =
        notificationsJson
            .map((str) => jsonDecode(str))
            .map((json) => NotificationData.fromJson(json))
            .toList();

    notifyListeners();
  }

  /// Save settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'notification_settings',
      jsonEncode(_settings.toJson()),
    );
  }

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('notification_settings');

    if (settingsJson != null) {
      try {
        final json = jsonDecode(settingsJson);
        _settings = NotificationSettings.fromJson(json);
      } catch (e) {
        debugPrint('Error loading notification settings: $e');
        _settings = NotificationSettings(); // Use defaults
      }
    }
  }

  @override
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  @override
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? payload,
  }) async {
    final notification = NotificationData(
      title: title,
      body: body,
      type: type,
      payload: payload,
    );

    await _addNotification(notification);
    await _showLocalNotification(notification);
  }

  @override
  Future<void> scheduleDailyRecommendationNotification(TimeOfDay time) async {
    if (!_settings.enableLocalNotifications ||
        !_settings.enableOutfitRecommendations) {
      return;
    }

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_recommendation_channel',
      'Daily Recommendation Notifications',
      channelDescription: 'Ежедневные рекомендации нарядов',
    );

    const iosPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.zonedSchedule(
      0,
      'Ежедневная рекомендация',
      'Время получить вашу персональную рекомендацию наряда!',
      _nextInstanceOfTime(time),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Calculate next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  @override
  Future<void> cancelScheduledNotification(int id) async {
    await _localNotificationsPlugin.cancel(id);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
      notifyListeners();
      await _saveNotifications();
    }
  }

  @override
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
    await _saveNotifications();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
    await _saveNotifications();
  }

  @override
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    notifyListeners();
    await _saveNotifications();
  }

  @override
  int getUnreadCount() {
    return _notifications.where((n) => !n.read).length;
  }

  @override
  List<NotificationData> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    final localEnabled =
        await _localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.areNotificationsEnabled() ??
        true;

    // For push notifications, we check if we have a token which indicates registration
    final token = await _firebaseMessaging.getToken();
    final pushEnabled = token != null;

    return localEnabled || pushEnabled;
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      // For push notifications (already handled in initialization)
      // Local notifications don't need explicit permission request on Android 13+
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  @override
  Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
