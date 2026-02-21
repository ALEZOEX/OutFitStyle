import '../entities/admin_user.dart';
import '../enums/user_role.dart';

/// Результат пагинации
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;

  const PaginatedResult({
    required this.items,
    required this.total,
    this.page = 1,
    this.limit = 50,
  });

  /// Общее количество страниц
  int get totalPages => (total / limit).ceil();

  /// Есть ли следующая страница
  bool get hasNextPage => page < totalPages;

  /// Есть ли предыдущая страница
  bool get hasPreviousPage => page > 1;
}

/// Фильтр для поиска пользователей
class UserFilter {
  final String? query;
  final UserRole? role;
  final bool? isActive;
  final bool? isVerified;

  const UserFilter({
    this.query,
    this.role,
    this.isActive,
    this.isVerified,
  });

  /// Преобразует фильтр в map для query параметров
  Map<String, dynamic> toQueryParams() {
    return {
      if (query != null && query!.isNotEmpty) 'q': query,
      if (role != null) 'role': role!.apiValue,
      if (isActive != null) 'is_active': isActive,
      if (isVerified != null) 'is_verified': isVerified,
    };
  }

  UserFilter copyWith({
    String? query,
    UserRole? role,
    bool? isActive,
    bool? isVerified,
  }) {
    return UserFilter(
      query: query ?? this.query,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

/// Интерфейс репозитория админ-панели
abstract class AdminRepository {
  /// Получает статистику админ-панели
  Future<Map<String, dynamic>> getStats();

  /// Получает список пользователей с пагинацией и фильтрами
  Future<PaginatedResult<AdminUser>> getUsers({
    int page = 1,
    int limit = 50,
    UserFilter? filter,
  });

  /// Получает детали пользователя по ID
  Future<AdminUser> getUserById(String userId);

  /// Обновляет роль пользователя
  Future<void> updateUserRole(String userId, UserRole role);

  /// Блокирует/разблокирует пользователя
  Future<void> blockUser(String userId, bool blocked);

  /// Сбрасывает пароль пользователя (административный сброс)
  Future<void> resetUserPassword(String userId);

  /// Удаляет пользователя (мягкое удаление)
  Future<void> deleteUser(String userId);
}
