/// Роль пользователя в системе
enum UserRole {
  user,
  admin,
  banned,
  unknown;

  factory UserRole.fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'banned':
        return UserRole.banned;
      case 'user':
        return UserRole.user;
      default:
        return UserRole.unknown;
    }
  }
}

/// Extension для удобной работы с ролями
extension UserRoleExtension on UserRole {
  /// Отображаемое название роли
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Пользователь';
      case UserRole.admin:
        return 'Администратор';
      case UserRole.banned:
        return 'Заблокирован';
      case UserRole.unknown:
        return 'Неизвестно';
    }
  }

  /// Строковое представление для API
  String get apiValue {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.admin:
        return 'admin';
      case UserRole.banned:
        return 'banned';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  /// Цвет для бейджа роли
  String get badgeColor {
    switch (this) {
      case UserRole.user:
        return '2196F3'; // Blue
      case UserRole.admin:
        return '4CAF50'; // Green
      case UserRole.banned:
        return 'F44336'; // Red
      case UserRole.unknown:
        return '9E9E9E'; // Grey
    }
  }
}
