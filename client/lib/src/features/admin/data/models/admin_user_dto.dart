import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';

part 'admin_user_dto.freezed.dart';
part 'admin_user_dto.g.dart';

/// DTO пользователя для админ-панели (ответ от API)
@freezed
abstract class AdminUserDto with _$AdminUserDto {
  const factory AdminUserDto({
    required String id,
    required String email,
    String? displayName,
    required bool isActive,
    required bool isVerified,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) = _AdminUserDto;

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
@freezed
abstract class UpdateUserRoleRequest with _$UpdateUserRoleRequest {
  const factory UpdateUserRoleRequest({
    required String role,
  }) = _UpdateUserRoleRequest;

  factory UpdateUserRoleRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserRoleRequest(
      role: json['role'] as String,
    );
  }
}

/// DTO для запроса блокировки пользователя
@freezed
abstract class BlockUserRequest with _$BlockUserRequest {
  const factory BlockUserRequest({
    required bool isActive,
  }) = _BlockUserRequest;

  factory BlockUserRequest.fromJson(Map<String, dynamic> json) {
    return BlockUserRequest(
      isActive: json['is_active'] as bool,
    );
  }
}

/// DTO для запроса сброса пароля
@freezed
abstract class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    required String userId,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequest(
      userId: json['user_id'] as String,
    );
  }
}
