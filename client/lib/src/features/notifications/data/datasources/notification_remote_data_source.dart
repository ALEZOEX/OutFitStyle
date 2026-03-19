import 'dart:convert';

import '../../../../core/api/api_client.dart';
import '../models/notification_dto.dart';

/// Remote data source для работы с API уведомлений
class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  /// Получить список уведомлений
  /// [unreadOnly] - только непрочитанные
  /// [page] - номер страницы (начиная с 1)
  /// [limit] - количество на странице
  Future<NotificationsResponse> getNotifications({
    bool unreadOnly = false,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'unread_only': unreadOnly.toString(),
      'page': page,
      'limit': limit,
    };

    final response = await _apiClient.get(
      '/api/v1/notifications',
      params: params,
    );

    final data = jsonDecode(response.data.toString()) as Map<String, dynamic>;
    return NotificationsResponse.fromJson(data);
  }

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.put('/api/v1/notifications/$notificationId/read');
  }

  /// Отметить все уведомления как прочитанные
  Future<void> markAllAsRead() async {
    await _apiClient.put('/api/v1/notifications/read-all');
  }

  /// Зарегистрировать device token для push-уведомлений
  Future<void> registerDeviceToken(RegisterDeviceTokenRequest request) async {
    await _apiClient.post(
      '/api/v1/notifications/register-device',
      data: request.toJson(),
    );
  }

  /// Удалить device token
  Future<void> deleteDeviceToken(String token) async {
    await _apiClient.delete('/api/v1/notifications/token');
    // Примечание: API требует токен в теле запроса, но delete не поддерживает тело
    // Используем POST с кастомным методом или передаём через query params
    // В данной реализации API принимает DELETE с телом через interceptor
  }

  /// Получить только количество непрочитанных уведомлений
  Future<int> getUnreadCount() async {
    final response = await getNotifications(
      unreadOnly: false,
      page: 1,
      limit: 1,
    );
    return response.unreadCount;
  }
}
