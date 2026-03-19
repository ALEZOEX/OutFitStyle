import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/admin_user.dart';
import '../widgets/user_role_badge.dart';

/// Карточка пользователя в списке админ-панели
class UserCard extends StatelessWidget {
  final AdminUser user;
  final VoidCallback? onBlockToggle;
  final VoidCallback? onRoleChange;
  final VoidCallback? onViewDetails;

  const UserCard({
    super.key,
    required this.user,
    this.onBlockToggle,
    this.onRoleChange,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstLetter =
        user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onViewDetails ?? () => context.push('/admin/users/${user.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Аватар
                  Container(
                    width: 56,
                    height: 56,
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Информация о пользователе
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? user.email,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Бейдж роли
                  UserRoleBadge(role: user.role),
                ],
              ),
              const SizedBox(height: 16),
              // Статус и действия
              Row(
                children: [
                  UserStatusBadge(
                    isActive: user.isActive,
                    isVerified: user.isVerified,
                  ),
                  const Spacer(),
                  // Кнопки действий
                  if (onBlockToggle != null)
                    TextButton.icon(
                      onPressed: onBlockToggle,
                      icon: Icon(
                        user.isActive ? Icons.block : Icons.lock_open,
                        size: 18,
                      ),
                      label: Text(
                        user.isActive ? 'Заблокировать' : 'Разблокировать',
                      ),
                    ),
                  if (onRoleChange != null)
                    TextButton.icon(
                      onPressed: onRoleChange,
                      icon: const Icon(Icons.admin_panel_settings, size: 18),
                      label: const Text('Роль'),
                    ),
                  IconButton(
                    onPressed:
                        onViewDetails ??
                        () => context.push('/admin/users/${user.id}'),
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    tooltip: 'Подробнее',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
