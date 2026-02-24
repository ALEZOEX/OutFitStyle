import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';

part 'admin_user_dto.freezed.dart';
part 'admin_user_dto.g.dart';

/// DTO пользователя для админ-панели (ответ от API)
@Freezed(anyMap: true)
abstract class AdminUserDto with _$AdminUserDto {
  const factory AdminUserDto({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'is_verified') required bool isVerified,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'last_login_at') DateTime? lastLoginAt,
  }) = _AdminUserDto;

  factory AdminUserDto.fromJson(Map<String, dynamic> json) =>
      _$AdminUserDtoFromJson(json);
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
@Freezed(anyMap: true)
abstract class UpdateUserRoleRequest with _$UpdateUserRoleRequest {
  const factory UpdateUserRoleRequest({
    @JsonKey(name: 'role') required String role,
  }) = _UpdateUserRoleRequest;

  factory UpdateUserRoleRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRoleRequestFromJson(json);
}

/// DTO для запроса блокировки пользователя
@Freezed(anyMap: true)
abstract class BlockUserRequest with _$BlockUserRequest {
  const factory BlockUserRequest({
    @JsonKey(name: 'is_active') required bool isActive,
  }) = _BlockUserRequest;

  factory BlockUserRequest.fromJson(Map<String, dynamic> json) =>
      _$BlockUserRequestFromJson(json);
}

/// DTO для запроса сброса пароля
@Freezed(anyMap: true)
abstract class ResetPasswordRequest with _$ResetPasswordRequest {
  const factory ResetPasswordRequest({
    @JsonKey(name: 'user_id') required String userId,
  }) = _ResetPasswordRequest;

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestFromJson(json);
}
