/// Модель сессии устройства пользователя
///
/// Используется для отображения активных сессий в настройках безопасности
class SessionDevice {
  final String id;
  final String deviceName;
  final String deviceType;
  final String? ipAddress;
  final DateTime lastUsedAt;
  final bool isCurrent;
  final bool isActive;
  final DateTime? expiresAt;

  const SessionDevice({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    this.ipAddress,
    required this.lastUsedAt,
    required this.isCurrent,
    required this.isActive,
    this.expiresAt,
  });

  /// Создать из JSON (ответ API)
  factory SessionDevice.fromJson(Map<String, dynamic> json) {
    return SessionDevice(
      id: json['id'] as String,
      deviceName: json['device_name'] as String? ?? 'Неизвестное устройство',
      deviceType: json['device_type'] as String? ?? 'unknown',
      ipAddress: json['ip_address'] as String?,
      lastUsedAt: DateTime.parse(json['last_used_at'] as String),
      isCurrent: json['is_current'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'] as String)
              : null,
    );
  }

  /// Преобразовать в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_type': deviceType,
      'ip_address': ipAddress,
      'last_used_at': lastUsedAt.toIso8601String(),
      'is_current': isCurrent,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Получить иконку для типа устройства
  String get iconCode {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
      case 'smartphone':
        return 'phone_iphone';
      case 'tablet':
        return 'tablet_mac';
      case 'desktop':
      case 'computer':
        return 'desktop_mac';
      case 'web':
        return 'language';
      default:
        return 'devices';
    }
  }

  /// Получить отображаемое название типа устройства
  String get deviceTypeLabel {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
      case 'smartphone':
        return 'Мобильное устройство';
      case 'tablet':
        return 'Планшет';
      case 'desktop':
      case 'computer':
        return 'Компьютер';
      case 'web':
        return 'Веб-браузер';
      default:
        return 'Устройство';
    }
  }

  /// Получить форматированное время последней активности
  String get lastActiveLabel {
    final now = DateTime.now();
    final difference = now.difference(lastUsedAt);

    if (difference.inMinutes < 1) {
      return 'Сейчас';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      // Форматируем дату
      final day = lastUsedAt.day.toString().padLeft(2, '0');
      final month = lastUsedAt.month.toString().padLeft(2, '0');
      return '$day.$month.$year';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionDevice &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deviceName == other.deviceName &&
          deviceType == other.deviceType &&
          ipAddress == other.ipAddress &&
          lastUsedAt == other.lastUsedAt &&
          isCurrent == other.isCurrent &&
          isActive == other.isActive &&
          expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hash(
    id,
    deviceName,
    deviceType,
    ipAddress,
    lastUsedAt,
    isCurrent,
    isActive,
    expiresAt,
  );

  @override
  String toString() {
    return 'SessionDevice(id: $id, deviceName: $deviceName, '
        'deviceType: $deviceType, isCurrent: $isCurrent, isActive: $isActive)';
  }
}
