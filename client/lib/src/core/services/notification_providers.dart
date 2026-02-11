import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return FirebaseNotificationService();
});

/// Async provider to initialize the notification service
final initializedNotificationServiceProvider =
    FutureProvider<NotificationService>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.initialize();
  return notificationService;
});

/// Provider for the notification settings
final notificationSettingsProvider = StateProvider<NotificationSettings>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.settings;
});

/// Provider for the list of notifications
final notificationsProvider = StateProvider<List<NotificationData>>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.notifications;
});

/// Provider for unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((notification) => !notification.read).length;
});
