import '../../../../core/api/api_client.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_dto.dart';

/// Repository для работы с уведомлениями
/// Инкапсулирует логику доступа к данным (API)
class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  /// Получить список уведомлений
  /// Возвращает кортеж: (список уведомлений, количество непрочитанных)
  Future<NotificationListResult> getNotifications({
    bool unreadOnly = false,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _remoteDataSource.getNotifications(
        unreadOnly: unreadOnly,
        page: page,
        limit: limit,
      );

      return NotificationListResult(
        notifications:
            response.notifications.map((dto) => dto.toModel()).toList(),
        unreadCount: response.unreadCount,
        total: response.total,
        hasMore: (page * limit) < response.total,
      );
    } on NetworkException catch (e) {
      throw NotificationException('Нет соединения: ${e.message}');
    } on ApiException catch (e) {
      throw NotificationException('Ошибка API: ${e.message}');
    } catch (e) {
      throw NotificationException('Неизвестная ошибка: $e');
    }
  }

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
    } on NetworkException catch (e) {
      throw NotificationException('Нет соединения: ${e.message}');
    } on ApiException catch (e) {
      throw NotificationException('Ошибка API: ${e.message}');
    } catch (e) {
      throw NotificationException('Неизвестная ошибка: $e');
    }
  }

  /// Отметить все уведомления как прочитанные
  Future<void> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
    } on NetworkException catch (e) {
      throw NotificationException('Нет соединения: ${e.message}');
    } on ApiException catch (e) {
      throw NotificationException('Ошибка API: ${e.message}');
    } catch (e) {
      throw NotificationException('Неизвестная ошибка: $e');
    }
  }

  /// Зарегистрировать device token для push-уведомлений
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
  }) async {
    try {
      final request = RegisterDeviceTokenRequest(
        token: token,
        platform: platform,
        deviceId: deviceId,
      );
      await _remoteDataSource.registerDeviceToken(request);
    } on NetworkException catch (e) {
      throw NotificationException('Нет соединения: ${e.message}');
    } on ApiException catch (e) {
      throw NotificationException('Ошибка API: ${e.message}');
    } catch (e) {
      throw NotificationException('Неизвестная ошибка: $e');
    }
  }

  /// Получить количество непрочитанных уведомлений
  Future<int> getUnreadCount() async {
    try {
      return await _remoteDataSource.getUnreadCount();
    } on NetworkException catch (e) {
      throw NotificationException('Нет соединения: ${e.message}');
    } on ApiException catch (e) {
      throw NotificationException('Ошибка API: ${e.message}');
    } catch (e) {
      throw NotificationException('Неизвестная ошибка: $e');
    }
  }
}

/// Результат получения списка уведомлений
class NotificationListResult {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int total;
  final bool hasMore;

  const NotificationListResult({
    required this.notifications,
    required this.unreadCount,
    required this.total,
    required this.hasMore,
  });
}

/// Исключение для ошибок репозитория уведомлений
class NotificationException implements Exception {
  final String message;

  const NotificationException(this.message);

  @override
  String toString() => 'NotificationException: $message';
}
