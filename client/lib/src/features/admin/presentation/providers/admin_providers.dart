import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/api/api_client.dart';
import '../../../../presentation/providers/session_provider.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/repositories/admin_repository.dart';

/// Провайдер AdminRemoteDataSource
final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  final config = const ApiConfig(
    apiBase: ApiConfig.baseUrl,
  );
  final apiClient = ref.watch(apiClientProvider);
  return AdminRemoteDataSource(config: config, apiClient: apiClient);
});

/// Провайдер AdminRepository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final remoteDataSource = ref.watch(adminRemoteDataSourceProvider);
  return AdminRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Состояние списка пользователей
class AdminUsersState {
  final bool isLoading;
  final String? error;
  final List<AdminUser> users;
  final int total;
  final int currentPage;
  final int totalPages;
  final UserFilter? filter;

  const AdminUsersState({
    this.isLoading = false,
    this.error,
    this.users = const [],
    this.total = 0,
    this.currentPage = 1,
    this.totalPages = 0,
    this.filter,
  });

  AdminUsersState copyWith({
    bool? isLoading,
    String? error,
    List<AdminUser>? users,
    int? total,
    int? currentPage,
    int? totalPages,
    UserFilter? filter,
  }) {
    return AdminUsersState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      users: users ?? this.users,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      filter: filter ?? this.filter,
    );
  }
}

/// Провайдер состояния списка пользователей
final adminUsersStateProvider = StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  return AdminUsersNotifier(ref.watch(adminRepositoryProvider));
});

/// Нотификер для управления состоянием пользователей
class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final AdminRepository _repository;

  AdminUsersNotifier(this._repository) : super(const AdminUsersState());

  /// Загружает пользователей с пагинацией и фильтрами
  Future<void> loadUsers({
    int page = 1,
    int limit = 50,
    UserFilter? filter,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getUsers(
        page: page,
        limit: limit,
        filter: filter ?? state.filter,
      );

      state = state.copyWith(
        isLoading: false,
        users: result.items,
        total: result.total,
        currentPage: result.page,
        totalPages: result.totalPages,
        filter: filter ?? state.filter,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Обновляет фильтр и перезагружает список
  Future<void> setFilter(UserFilter filter) async {
    state = state.copyWith(filter: filter);
    await loadUsers(page: 1, filter: filter);
  }

  /// Сбрасывает фильтр
  Future<void> clearFilter() async {
    state = state.copyWith(filter: null);
    await loadUsers(page: 1);
  }

  /// Переход на следующую страницу
  Future<void> nextPage() async {
    if (state.currentPage < state.totalPages) {
      await loadUsers(page: state.currentPage + 1);
    }
  }

  /// Переход на предыдущую страницу
  Future<void> previousPage() async {
    if (state.currentPage > 1) {
      await loadUsers(page: state.currentPage - 1);
    }
  }

  /// Обновляет роль пользователя в локальном состоянии
  void updateUserRoleLocally(String userId, UserRole role) {
    final updatedUsers = state.users.map((user) {
      if (user.id == userId) {
        return user.copyWith(role: role);
      }
      return user;
    }).toList();
    state = state.copyWith(users: updatedUsers);
  }

  /// Обновляет статус блокировки в локальном состоянии
  void updateUserBlockStatusLocally(String userId, bool isActive) {
    final updatedUsers = state.users.map((user) {
      if (user.id == userId) {
        return user.copyWith(isActive: isActive);
      }
      return user;
    }).toList();
    state = state.copyWith(users: updatedUsers);
  }
}

/// Провайдер для операций с пользователем
final adminUserActionsProvider = Provider<AdminUserActions>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  final notifier = ref.watch(adminUsersStateProvider.notifier);
  return AdminUserActions(repository, notifier);
});

/// Класс для действий над пользователем
class AdminUserActions {
  final AdminRepository _repository;
  final AdminUsersNotifier _notifier;

  AdminUserActions(this._repository, this._notifier);

  /// Обновляет роль пользователя
  Future<void> updateUserRole(String userId, UserRole role) async {
    await _repository.updateUserRole(userId, role);
    _notifier.updateUserRoleLocally(userId, role);
  }

  /// Блокирует/разблокирует пользователя
  Future<void> blockUser(String userId, bool blocked) async {
    await _repository.blockUser(userId, blocked);
    _notifier.updateUserBlockStatusLocally(userId, !blocked);
  }

  /// Сбрасывает пароль пользователя
  Future<void> resetPassword(String userId) async {
    await _repository.resetUserPassword(userId);
  }

  /// Удаляет пользователя
  Future<void> deleteUser(String userId) async {
    await _repository.deleteUser(userId);
    // Перезагружаем список после удаления
    await _notifier.loadUsers();
  }
}
