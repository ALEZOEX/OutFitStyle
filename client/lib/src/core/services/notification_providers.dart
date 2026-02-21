import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_service.dart';

/// Provider for the notification service (legacy)
final legacyNotificationServiceProvider = Provider<NotificationService>((ref) {
  return FirebaseNotificationService();
});

/// Async provider to initialize the notification service (legacy)
final initializedLegacyNotificationServiceProvider =
    FutureProvider<NotificationService>((ref) async {
  final notificationService = ref.watch(legacyNotificationServiceProvider);
  await notificationService.initialize();
  return notificationService;
});

/// Provider for the notification settings (legacy)
final legacyNotificationSettingsProvider = StateProvider<NotificationSettings>((ref) {
  final notificationService = ref.watch(legacyNotificationServiceProvider);
  return notificationService.settings;
});

/// Provider for the list of notifications (legacy)
final legacyNotificationsProvider = StateProvider<List<NotificationData>>((ref) {
  final notificationService = ref.watch(legacyNotificationServiceProvider);
  return notificationService.notifications;
});

/// Provider for unread notifications count (legacy)
final legacyUnreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(legacyNotificationsProvider);
  return notifications.where((notification) => !notification.read).length;
});
