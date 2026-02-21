import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

/// Converter для UserRole
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) => UserRole.fromJson(json);

  @override
  String toJson(UserRole role) => role.apiValue;
}

/// Пользователь для админ-панели
@freezed
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    /// Уникальный идентификатор пользователя
    required String id,

    /// Электронная почта
    required String email,

    /// Отображаемое имя
    String? displayName,

    /// Активен ли пользователь
    required bool isActive,

    /// Подтвержден ли аккаунт
    required bool isVerified,

    /// Дата создания аккаунта
    required DateTime createdAt,

    /// Дата последнего входа
    DateTime? lastLoginAt,

    /// Роль пользователя
    @Default(UserRole.user) @UserRoleConverter() UserRole role,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}

/// Extension для удобного доступа к статусу блокировки
extension AdminUserExtension on AdminUser {
  /// Заблокирован ли пользователь
  bool get isBanned => role == UserRole.banned;

  /// Является ли пользователем администратором
  bool get isAdmin => role == UserRole.admin;

  /// Может ли быть изменена роль (нельзя изменить роль самому себе)
  bool canChangeRole(String currentUserId) => id != currentUserId;

  /// Может ли быть заблокирован (нельзя заблокировать самого себя)
  bool canBeBlocked(String currentUserId) => id != currentUserId;
}
