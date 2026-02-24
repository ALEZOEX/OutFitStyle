import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';

/// DTO пользователя для админ-панели (ответ от API)
class AdminUserDto {
  const AdminUserDto({
    required this.id,
    required this.email,
    this.displayName,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    return AdminUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  final String id;
  final String email;
  final String? displayName;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

/// Extension для конвертации DTO в domain entity
extension AdminUserDtoExtension on AdminUserDto {
  /// Преобразует DTO в AdminUser entity
  AdminUser toEntity() {
    return AdminUser(
      id: id,
      email: email,
      displayName: displayName,
      isActive: isActive,
      isVerified: isVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      role: UserRole.user, // По умолчанию user, роль можно определить по is_active
    );
  }
}

/// DTO для запроса обновления роли
class UpdateUserRoleRequest {
  const UpdateUserRoleRequest({required this.role});

  factory UpdateUserRoleRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRoleRequest(
      role: json['role'] as String,
    );
  }

  final String role;

  Map<String, dynamic> toJson() {
    return {
      'role': role,
    };
  }
}

/// DTO для запроса блокировки пользователя
class BlockUserRequest {
  const BlockUserRequest({required this.isActive});

  factory BlockUserRequest.fromJson(Map<String, dynamic> json) {
    return BlockUserRequest(
      isActive: json['is_active'] as bool,
    );
  }

  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
    };
  }
}

/// DTO для запроса сброса пароля
class ResetPasswordRequest {
  const ResetPasswordRequest({required this.userId});

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      userId: json['user_id'] as String,
    );
  }

  final String userId;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}
