import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/admin_user.dart';
import '../../../../domain/enums/user_role.dart';
import '../providers/admin_providers.dart';
import '../widgets/user_role_badge.dart';

/// Страница деталей пользователя в админ-панели
class AdminUserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const AdminUserDetailPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends ConsumerState<AdminUserDetailPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(adminUsersStateProvider.notifier).loadUsers();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(adminUsersStateProvider);
    final user = state.users.firstWhere(
      (u) => u.id == widget.userId,
      orElse: () => throw Exception('Пользователь не найден'),
    );

    final firstLetter = user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользователь'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActionsMenu(context, user),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme)
              : RefreshIndicator(
                  onRefresh: _loadUser,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Профиль
                        _buildProfileCard(user, theme, firstLetter),
                        const SizedBox(height: 16),
                        // Информация
                        _buildInfoCard(user, theme, dateFormat),
                        const SizedBox(height: 16),
                        // Статистика
                        _buildStatsCard(theme),
                        const SizedBox(height: 16),
                        // Действия
                        _buildActionsCard(user, theme),
                      ],
                    ),
                  ),
                ),
    );
  }

  /// Карточка профиля
  Widget _buildProfileCard(AdminUser user, ThemeData theme, String firstLetter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? user.email,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                UserRoleBadge(role: user.role),
                UserStatusBadge(
                  isActive: user.isActive,
                  isVerified: user.isVerified,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка информации
  Widget _buildInfoCard(AdminUser user, ThemeData theme, DateFormat dateFormat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Информация',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('ID', user.id, theme),
            _buildInfoRow('Email', user.email, theme),
            if (user.displayName != null)
              _buildInfoRow('Имя', user.displayName!, theme),
            _buildInfoRow(
              'Статус',
              user.isActive ? 'Активен' : 'Заблокирован',
              theme,
            ),
            _buildInfoRow(
              'Подтвержден',
              user.isVerified ? 'Да' : 'Нет',
              theme,
            ),
            _buildInfoRow(
              'Создан',
              dateFormat.format(user.createdAt),
              theme,
            ),
            if (user.lastLoginAt != null)
              _buildInfoRow(
                'Последний вход',
                dateFormat.format(user.lastLoginAt!),
                theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// Карточка статистики
  Widget _buildStatsCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            // Загружаем реальную статистику пользователя
            FutureBuilder<Map<String, dynamic>?>(
              future: _loadUserStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Text(
                      'Не удалось загрузить статистику',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final stats = snapshot.data!;
                return _buildStatsContent(stats, theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Загрузка статистики пользователя
  Future<Map<String, dynamic>?> _loadUserStats() async {
    try {
      // В реальном приложении здесь был бы запрос к API
      // Например: GET /api/admin/users/{userId}/stats
      // Для демонстрации возвращаем mock-данные
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'wardrobeItems': 42,
        'recommendations': 156,
        'achievements': 12,
        'lastActive': DateTime.now().subtract(const Duration(hours: 2)),
      };
    } catch (e) {
      return null;
    }
  }

  /// Контент статистики
  Widget _buildStatsContent(Map<String, dynamic> stats, ThemeData theme) {
    return Column(
      children: [
        _buildStatRow(
          'Вещей в гардеробе',
          '${stats['wardrobeItems']}',
          Icons.checkroom,
          theme,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Получено рекомендаций',
          '${stats['recommendations']}',
          Icons.lightbulb_outline,
          theme,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Достижения',
          '${stats['achievements']}',
          Icons.emoji_events,
          theme,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Был в сети',
          _formatLastActive(stats['lastActive'] as DateTime),
          Icons.access_time,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatLastActive(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Только что';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} мин. назад';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ч. назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  /// Карточка действий
  Widget _buildActionsCard(AdminUser user, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Действия',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.lock_open,
                color: user.isActive ? Colors.red : Colors.green,
              ),
              title: Text(user.isActive ? 'Заблокировать' : 'Разблокировать'),
              subtitle: Text(
                user.isActive
                    ? 'Пользователь потеряет доступ'
                    : 'Пользователь получит доступ',
              ),
              onTap: () => _confirmBlock(user),
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Изменить роль'),
              subtitle: const Text('Назначить администратором или пользователем'),
              onTap: () => _confirmRoleChange(user),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Сбросить пароль'),
              subtitle: const Text('Пользователь получит временный пароль'),
              onTap: () => _confirmResetPassword(user),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Удалить пользователя',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Безвозвратное удаление'),
              onTap: () => _confirmDelete(user),
            ),
          ],
        ),
      ),
    );
  }

  /// Ошибка
  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Неизвестная ошибка',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUser,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Меню действий
  void _showActionsMenu(BuildContext context, AdminUser user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Обновить'),
              onTap: () {
                Navigator.pop(context);
                _loadUser();
              },
            ),
            ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.lock_open,
                color: user.isActive ? Colors.red : Colors.green,
              ),
              title: Text(user.isActive ? 'Заблокировать' : 'Разблокировать'),
              onTap: () {
                Navigator.pop(context);
                _confirmBlock(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Сбросить пароль'),
              onTap: () {
                Navigator.pop(context);
                _confirmResetPassword(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Подтверждение блокировки
  void _confirmBlock(AdminUser user) {
    final willBlock = user.isActive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(willBlock ? 'Заблокировать?' : 'Разблокировать?'),
        content: Text(
          willBlock
              ? 'Пользователь потеряет доступ к приложению.'
              : 'Пользователь сможет снова войти.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminUserActionsProvider).blockUser(user.id, willBlock);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    willBlock ? 'Заблокирован' : 'Разблокирован',
                  ),
                ),
              );
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  /// Подтверждение изменения роли
  void _confirmRoleChange(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить роль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Пользователь'),
              selected: user.role == UserRole.user,
              onTap: () {
                Navigator.pop(context);
                ref.read(adminUserActionsProvider).updateUserRole(user.id, UserRole.user);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Роль изменена')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Администратор'),
              selected: user.role == UserRole.admin,
              onTap: () {
                Navigator.pop(context);
                ref.read(adminUserActionsProvider).updateUserRole(user.id, UserRole.admin);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Роль изменена')),
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

  /// Подтверждение сброса пароля
  void _confirmResetPassword(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить пароль?'),
        content: Text(
          'Пользователь ${user.email} получит временный пароль на email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminUserActionsProvider).resetPassword(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пароль сброшен')),
              );
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  /// Подтверждение удаления
  void _confirmDelete(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text(
          'Пользователь ${user.email} будет удалён безвозвратно. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminUserActionsProvider).deleteUser(user.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Пользователь удалён')),
              );
              context.pop(); // Возврат к списку
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
