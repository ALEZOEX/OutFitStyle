import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';
import '../../../../domain/repositories/admin_repository.dart';
import '../providers/admin_providers.dart';
import '../widgets/user_card.dart';

/// Страница списка пользователей в админ-панели
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _searchController = TextEditingController();
  UserRole? _selectedRole;
  bool? _isActive;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Загружаем пользователей при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUsersStateProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(adminUsersStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => ref.read(adminUsersStateProvider.notifier).loadUsers(),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Поиск и фильтры
          _buildSearchAndFilters(theme),
          // Список пользователей
          Expanded(
            child:
                state.isLoading && state.users.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null && state.users.isEmpty
                    ? _buildError(state.error!, theme)
                    : _buildUserList(state, theme),
          ),
        ],
      ),
    );
  }

  /// Поиск и фильтры
  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Поле поиска
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск по email или имени',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _isSearching
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                      : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() => _isSearching = value.isNotEmpty);
              _debouncedSearch();
            },
            onSubmitted: (_) => _applyFilters(),
          ),
          const SizedBox(height: 12),
          // Фильтры
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoleFilterChip('Все', null, theme),
                _buildRoleFilterChip('Пользователи', UserRole.user, theme),
                _buildRoleFilterChip('Админы', UserRole.admin, theme),
                _buildRoleFilterChip('Заблокированные', UserRole.banned, theme),
                const SizedBox(width: 8),
                _buildStatusFilterChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Чип фильтра по роли
  Widget _buildRoleFilterChip(String label, UserRole? role, ThemeData theme) {
    final isSelected = _selectedRole == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedRole = selected ? role : null);
          _applyFilters();
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        checkmarkColor: theme.colorScheme.primary,
      ),
    );
  }

  /// Чип фильтра по статусу
  Widget _buildStatusFilterChip() {
    final label =
        _isActive == null
            ? 'Все статусы'
            : _isActive!
            ? 'Активные'
            : 'Неактивные';
    return PopupMenuButton<bool?>(
      initialValue: _isActive,
      onSelected: (value) {
        setState(() => _isActive = value);
        _applyFilters();
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(value: null, child: Text('Все статусы')),
            const PopupMenuItem(value: true, child: Text('Активные')),
            const PopupMenuItem(value: false, child: Text('Неактивные')),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              _isActive == null
                  ? Colors.grey.shade200
                  : _isActive!
                  ? Colors.green.shade100
                  : Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color:
                    _isActive == null
                        ? Colors.black87
                        : _isActive!
                        ? Colors.green.shade800
                        : Colors.red.shade800,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  /// Список пользователей
  Widget _buildUserList(AdminUsersState state, ThemeData theme) {
    return Column(
      children: [
        // Информация о количестве
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Найдено: ${state.total}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              if (state.filter != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedRole = null;
                      _isActive = null;
                      _searchController.clear();
                    });
                    ref.read(adminUsersStateProvider.notifier).clearFilter();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Сбросить фильтры'),
                ),
            ],
          ),
        ),
        // Список
        Expanded(
          child: ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return UserCard(
                user: user,
                onViewDetails: () => context.push('/admin/users/${user.id}'),
                onBlockToggle: () => _showBlockDialog(user),
                onRoleChange: () => _showRoleDialog(user),
              );
            },
          ),
        ),
        // Пагинация
        if (state.totalPages > 1) _buildPagination(state, theme),
      ],
    );
  }

  /// Пагинация
  Widget _buildPagination(AdminUsersState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed:
                state.currentPage > 1
                    ? () =>
                        ref
                            .read(adminUsersStateProvider.notifier)
                            .previousPage()
                    : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            'Стр. ${state.currentPage} из ${state.totalPages}',
            style: theme.textTheme.bodyMedium,
          ),
          IconButton(
            onPressed:
                state.currentPage < state.totalPages
                    ? () =>
                        ref.read(adminUsersStateProvider.notifier).nextPage()
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  /// Ошибка
  Widget _buildError(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Ошибка загрузки', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed:
                  () => ref.read(adminUsersStateProvider.notifier).loadUsers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Применяет фильтры с debounce для поиска
  Timer? _debounceTimer;
  void _debouncedSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  /// Применяет текущие фильтры
  void _applyFilters() {
    final query = _searchController.text.trim();
    final filter = UserFilter(
      query: query.isNotEmpty ? query : null,
      role: _selectedRole,
      isActive: _isActive,
    );
    ref.read(adminUsersStateProvider.notifier).setFilter(filter);
  }

  /// Диалог блокировки
  void _showBlockDialog(AdminUser user) {
    final willBlock = user.isActive;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              willBlock
                  ? 'Заблокировать пользователя?'
                  : 'Разблокировать пользователя?',
            ),
            content: Text(
              willBlock
                  ? 'Пользователь ${user.email} потеряет доступ к приложению.'
                  : 'Пользователь ${user.email} сможет снова войти в приложение.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(adminUserActionsProvider)
                      .blockUser(user.id, willBlock);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        willBlock
                            ? 'Пользователь заблокирован'
                            : 'Пользователь разблокирован',
                      ),
                    ),
                  );
                },
                child: Text(willBlock ? 'Заблокировать' : 'Разблокировать'),
              ),
            ],
          ),
    );
  }

  /// Диалог изменения роли
  void _showRoleDialog(AdminUser user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Изменить роль'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Пользователь'),
                  subtitle: const Text('Обычный пользователь'),
                  selected: user.role == UserRole.user,
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(adminUserActionsProvider)
                        .updateUserRole(user.id, UserRole.user);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Роль изменена на "Пользователь"'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text('Администратор'),
                  subtitle: const Text('Полный доступ к админ-панели'),
                  selected: user.role == UserRole.admin,
                  onTap: () {
                    Navigator.pop(context);
                    ref
                        .read(adminUserActionsProvider)
                        .updateUserRole(user.id, UserRole.admin);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Роль изменена на "Администратор"'),
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ],
          ),
    );
  }
}
