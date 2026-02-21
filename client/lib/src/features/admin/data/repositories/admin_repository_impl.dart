import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../models/admin_user_dto.dart';

/// Реализация репозитория админ-панели
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getStats() async {
    return await remoteDataSource.getStats();
  }

  @override
  Future<PaginatedResult<AdminUser>> getUsers({
    int page = 1,
    int limit = 50,
    UserFilter? filter,
  }) async {
    final filters = filter?.toQueryParams();
    final result = await remoteDataSource.getUsers(
      page: page,
      limit: limit,
      filters: filters,
    );

    // Парсим пользователей из ответа
    final usersJson = result['users'] as List<dynamic>? ?? [];
    final users = usersJson
        .map((json) => AdminUserDto.fromJson(json as Map<String, dynamic>).toEntity())
        .toList();

    // Парсим пагинацию
    final pagination = result['pagination'] as Map<String, dynamic>?;
    final total = pagination?['total'] as int? ?? users.length;

    return PaginatedResult<AdminUser>(
      items: users,
      total: total,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<AdminUser> getUserById(String userId) async {
    final dto = await remoteDataSource.getUserById(userId);
    return dto.toEntity();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole role) async {
    await remoteDataSource.updateUserRole(userId, role.apiValue);
  }

  @override
  Future<void> blockUser(String userId, bool blocked) async {
    await remoteDataSource.blockUser(userId, blocked);
  }

  @override
  Future<void> resetUserPassword(String userId) async {
    await remoteDataSource.resetUserPassword(userId);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await remoteDataSource.deleteUser(userId);
  }
}
