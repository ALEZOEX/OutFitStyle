/// DTO для уведомления с сервера
class NotificationDto {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final bool isRead;
  final DateTime? readAt;
  final bool pushSent;
  final DateTime? pushSentAt;
  final String? pushError;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const NotificationDto({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.imageUrl,
    this.data,
    this.actionType,
    this.actionData,
    this.isRead = false,
    this.readAt,
    this.pushSent = false,
    this.pushSentAt,
    this.pushError,
    required this.createdAt,
    this.expiresAt,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      imageUrl: json['image_url'] as String?,
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      actionType: json['action_type'] as String?,
      actionData:
          json['action_data'] != null
              ? Map<String, dynamic>.from(json['action_data'])
              : null,
      isRead: json['is_read'] as bool? ?? false,
      readAt:
          json['read_at'] != null
              ? DateTime.parse(json['read_at'] as String)
              : null,
      pushSent: json['push_sent'] as bool? ?? false,
      pushSentAt:
          json['push_sent_at'] != null
              ? DateTime.parse(json['push_sent_at'] as String)
              : null,
      pushError: json['push_error'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'data': data,
      'action_type': actionType,
      'action_data': actionData,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'push_sent': pushSent,
      'push_sent_at': pushSentAt?.toIso8601String(),
      'push_error': pushError,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Преобразование в UI-модель
  NotificationModel toModel() {
    return NotificationModel(
      id: id,
      title: title,
      message: body ?? '',
      timestamp: createdAt,
      isRead: isRead,
      type: type,
      imageUrl: imageUrl,
      actionType: actionType,
      actionData: actionData,
    );
  }
}

/// UI-модель уведомления (расширенная версия существующей)
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type;
  final String? imageUrl;
  final String? actionType;
  final Map<String, dynamic>? actionData;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'info',
    this.imageUrl,
    this.actionType,
    this.actionData,
  });

  /// Создать копию с изменённым статусом прочтения
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      imageUrl: imageUrl,
      actionType: actionType,
      actionData: actionData,
    );
  }
}

/// Ответ API со списком уведомлений
class NotificationsResponse {
  final List<NotificationDto> notifications;
  final int unreadCount;
  final int page;
  final int limit;
  final int total;

  const NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final notificationsJson = json['notifications'] as List<dynamic>;
    final pagination = json['pagination'] as Map<String, dynamic>;

    return NotificationsResponse(
      notifications:
          notificationsJson
              .map((n) => NotificationDto.fromJson(n as Map<String, dynamic>))
              .toList(),
      unreadCount: json['unread_count'] as int? ?? 0,
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 20,
      total: pagination['total'] as int? ?? 0,
    );
  }
}

/// Запрос для регистрации device token
class RegisterDeviceTokenRequest {
  final String token;
  final String platform;
  final String? deviceId;

  const RegisterDeviceTokenRequest({
    required this.token,
    required this.platform,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'platform': platform,
      if (deviceId != null) 'device_id': deviceId,
    };
  }
}

/// Запрос для удаления device token
class DeleteDeviceTokenRequest {
  final String token;

  const DeleteDeviceTokenRequest({required this.token});

  Map<String, dynamic> toJson() {
    return {'token': token};
  }
}
