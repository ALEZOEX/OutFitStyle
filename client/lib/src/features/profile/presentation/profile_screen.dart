import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../presentation/routing/router.dart';
import '../../achievements/presentation/providers/achievements_providers.dart';
import 'providers/profile_provider.dart';
import '../../admin/presentation/providers/admin_auth_provider.dart';

/// Экран профиля пользователя
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);
    final profileState = ref.watch(profileDataProvider);
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок профиля
          SliverToBoxAdapter(
            child: _buildProfileHeader(context, profileState),
          ),
          // Статистика
          SliverToBoxAdapter(
            child: _buildStats(context, stats, profileState),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          // Меню настроек
          SliverToBoxAdapter(
            child: _buildSettingsMenu(context),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
          // Дополнительные опции
          SliverToBoxAdapter(
            child: _buildAdditionalOptions(context),
          ),
          // Кнопка выхода
          SliverToBoxAdapter(
            child: _buildLogoutButton(context, authRepository),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// Заголовок профиля
  Widget _buildProfileHeader(BuildContext context, AsyncValue<ProfileData> profileState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Аватар и данные пользователя
          profileState.when(
            data: (profile) {
              final avatarUrl = profile.photoUrl;
              final firstLetter = profile.firstLetter;
              final displayName = profile.displayName;
              final email = profile.email;

              return Column(
                children: [
                  // Аватар
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
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) {
                                return Center(
                                  child: Text(
                                    firstLetter,
                                    style: theme.textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              firstLetter,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                  // Скрытая кнопка админ-панели (долгое нажатие)
                  GestureDetector(
                    onLongPress: () async {
                      final adminAuth = ref.read(adminAuthProvider);
                      final isAdmin = await adminAuth.isAdmin();
                      if (!context.mounted) return;
                      if (isAdmin) {
                        context.push('/admin');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Требуется роль администратора'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  // Имя пользователя
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
            loading: () => const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Загрузка профиля...'),
              ],
            ),
            error: (error, stack) => Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ошибка загрузки профиля',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Статистика пользователя
  Widget _buildStats(BuildContext context, ProfileStats stats, AsyncValue<ProfileData> profileState) {
    final theme = Theme.of(context);
    final achievementsStats = ref.watch(achievementsStatsProvider);

    // Получаем количество дней в приложении из профиля
    final daysInApp = profileState.when(
      data: (profile) => profile.daysInApp,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final statsData = [
      {'label': 'Вещей', 'value': stats.totalCount.toString(), 'icon': Icons.checkroom},
      {'label': 'Категорий', 'value': stats.categoriesCount.toString(), 'icon': Icons.category},
      {'label': 'Избранное', 'value': stats.favoritesCount.toString(), 'icon': Icons.favorite},
      {'label': 'Дней', 'value': daysInApp.toString(), 'icon': Icons.calendar_today},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Статистика',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: statsData.map((stat) {
              return _buildStatItem(context, stat);
            }).toList(),
          ),
          // Статистика достижений
          const SizedBox(height: 16),
          _buildAchievementsStats(context, achievementsStats),
        ],
      ),
    );
  }

  /// Статистика достижений в профиле
  Widget _buildAchievementsStats(BuildContext context, AchievementStats stats) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.push('/achievements'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.5),
              theme.colorScheme.secondaryContainer.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Достижения',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats.progressText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Прогресс бар
            SizedBox(
              width: 80,
              child: Column(
                children: [
                  Text(
                    '${stats.progressPercent.round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: stats.progressPercent / 100,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Элемент статистики
  Widget _buildStatItem(BuildContext context, Map<String, dynamic> stat) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            stat['icon'] as IconData,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stat['value'] as String,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          stat['label'] as String,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Меню настроек
  Widget _buildSettingsMenu(BuildContext context) {
    final theme = Theme.of(context);

    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.person_outline,
        'label': 'Профиль и аккаунт',
        'route': '/settings/profile',
        'color': Colors.blue,
      },
      {
        'icon': Icons.palette_outlined,
        'label': 'Предпочтения',
        'route': '/settings/preferences',
        'color': Colors.purple,
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Уведомления',
        'route': '/notifications',
        'color': Colors.orange,
      },
      {
        'icon': Icons.emoji_events_outlined,
        'label': 'Достижения',
        'route': '/achievements',
        'color': Colors.green,
      },
      {
        'icon': Icons.help_outline,
        'label': 'Помощь и поддержка',
        'route': '/support',
        'color': Colors.teal,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          final index = menuItems.indexOf(item);
          final isLast = index == menuItems.length - 1;

          return InkWell(
            onTap: () {
              // Для несуществующих маршрутов показываем заглушку
              if (item['route'] == '/notifications' ||
                  item['route'] == '/support') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Раздел "${item['label']}" скоро будет доступен'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                context.push(item['route'] as String);
              }
            },
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(20) : Radius.zero,
              bottom: isLast ? const Radius.circular(20) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['label'] as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Дополнительные опции
  Widget _buildAdditionalOptions(BuildContext context) {
    final theme = Theme.of(context);

    final options = <Map<String, dynamic>>[
      {'icon': Icons.security_outlined, 'label': 'Безопасность'},
      {'icon': Icons.language_outlined, 'label': 'Язык'},
      {'icon': Icons.info_outline, 'label': 'О приложении'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: options.map((option) {
          final index = options.indexOf(option);
          final isLast = index == options.length - 1;

          return InkWell(
            onTap: () {
              // Показываем сообщение о том, что раздел скоро будет доступен
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Раздел "${option['label']}" скоро будет доступен'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(20) : Radius.zero,
              bottom: isLast ? const Radius.circular(20) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      option['icon'] as IconData,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    option['label'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Кнопка выхода
  Widget _buildLogoutButton(BuildContext context, AuthRepository authRepository) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context, authRepository),
          icon: const Icon(Icons.logout),
          label: const Text('Выйти из аккаунта'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// Диалог подтверждения выхода
  void _showLogoutDialog(BuildContext context, AuthRepository authRepository) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.logout,
            color: Colors.red,
            size: 32,
          ),
        ),
        title: const Text(
          'Выйти из аккаунта?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Вы будете перенаправлены на экран входа',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              await authRepository.logout();
              if (context.mounted) {
                context.go('/auth');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
