// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/session_manager.dart';
import '../../../presentation/providers/session_provider.dart';
import '../../../theme/theme_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/widgets/max_width_container.dart';
import '../../achievements/data/repositories/achievements_repository.dart';
import '../../achievements/presentation/providers/achievements_providers.dart';
import 'providers/profile_provider.dart';
import '../../admin/presentation/providers/admin_auth_provider.dart';

/// Экран профиля пользователя — обновлённый дизайн
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileDataProvider);
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      body: ResponsiveMaxWidthContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(context, profileState, ref),
            ),
            SliverToBoxAdapter(
              child: _buildStats(context, stats, profileState, ref),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            SliverToBoxAdapter(child: _buildSettingsMenu(context, ref)),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            SliverToBoxAdapter(child: _buildAdditionalOptions(context)),
            SliverToBoxAdapter(child: _buildLogoutButtonFromRef(context, ref)),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AsyncValue<ProfileData> profileState,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          profileState.when(
            data: (profile) {
              final avatarUrl = profile.photoUrl;
              final firstLetter = profile.firstLetter;
              final displayName = profile.displayName;
              final email = profile.email;

              return Column(
                children: [
                  // Градиентный аватар — Landing style
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
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
                                    style: AppTypography.headlineLarge(
                                      context,
                                    ).copyWith(color: Colors.white),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                            ),
                          )
                        : Center(
                            child: Text(
                              firstLetter,
                              style: AppTypography.headlineLarge(
                                context,
                              ).copyWith(color: Colors.white),
                            ),
                          ),
                  ),
                  // Скрытая кнопка админ-панели
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
                            backgroundColor: AppColors.warning,
                          ),
                        );
                      }
                    },
                    child: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    displayName,
                    style: AppTypography.headlineSmall(context),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    email,
                    style: AppTypography.bodyMedium(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
            loading: () => const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: AppSpacing.lg),
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ошибка загрузки профиля',
                  style: AppTypography.bodyLarge(
                    context,
                  ).copyWith(color: theme.colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error.toString(),
                  style: AppTypography.bodySmall(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    ProfileStats stats,
    AsyncValue<ProfileData> profileState,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final achievementsStats = ref.watch(achievementsStatsProvider);

    final statsData = [
      {
        'label': 'Вещей',
        'value': stats.totalCount.toString(),
        'icon': Icons.checkroom,
      },
      {
        'label': 'Избранное',
        'value': stats.favoritesCount.toString(),
        'icon': Icons.favorite,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.radiusXl,
      ),
      child: Column(
        children: [
          Text('Статистика', style: AppTypography.labelLarge(context)),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            alignment: WrapAlignment.center,
            children: statsData
                .map((stat) => _buildStatItem(context, stat))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildAchievementsStats(context, achievementsStats),
        ],
      ),
    );
  }

  Widget _buildAchievementsStats(BuildContext context, AchievementStats stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push('/achievements'),
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.cardDark : AppGradients.cardLight,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: AppRadius.radiusSm,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Достижения',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stats.progressText,
                    style: AppTypography.bodySmall(context),
                  ),
                ],
              ),
            ),
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
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: LinearProgressIndicator(
                      value: stats.progressPercent / 100,
                      backgroundColor: theme.colorScheme.outline.withValues(
                        alpha: 0.2,
                      ),
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

  Widget _buildStatItem(BuildContext context, Map<String, dynamic> stat) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.radiusMd,
          ),
          child: Icon(
            stat['icon'] as IconData,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          stat['value'] as String,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(stat['label'] as String, style: AppTypography.labelSmall(context)),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    final menuItems = <Map<String, dynamic>>[
      {
        'icon': Icons.person_outline,
        'label': 'Профиль и аккаунт',
        'route': '/settings/profile',
        'color': AppColors.info,
      },
      {
        'icon': Icons.palette_outlined,
        'label': 'Предпочтения',
        'route': '/settings/preferences',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.notifications_outlined,
        'label': 'Уведомления',
        'route': '/notifications',
        'color': AppColors.warning,
      },
      {
        'icon': Icons.emoji_events_outlined,
        'label': 'Достижения',
        'route': '/achievements',
        'color': AppColors.success,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
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
        children: [
          _buildThemeTile(context, themeMode, ref),
          ...menuItems.map((item) {
            final index = menuItems.indexOf(item);
            final isLast = index == menuItems.length - 1;

            return InkWell(
              onTap: () => context.push(item['route'] as String),
              borderRadius: BorderRadius.vertical(
                top: index == 0
                    ? const Radius.circular(AppRadius.xl)
                    : Radius.zero,
                bottom: isLast
                    ? const Radius.circular(AppRadius.xl)
                    : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(
                        AppSpacing.sm + AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: AppRadius.radiusMd,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: AppTypography.bodyLarge(context),
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
          }),
        ],
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    ThemeMode themeMode,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final themeText = switch (themeMode) {
      ThemeMode.dark => 'Тёмная',
      ThemeMode.light => 'Светлая',
      ThemeMode.system => 'Системная',
    };

    return InkWell(
      onTap: () => _showThemeSelectionDialog(context, ref),
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(
                Icons.brightness_6,
                color: theme.colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Тема',
                    style: AppTypography.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(themeText, style: AppTypography.bodySmall(context)),
                ],
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
  }

  void _showThemeSelectionDialog(BuildContext context, WidgetRef ref) {
    final themeMode = ref.read(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите тему'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Светлая'),
              subtitle: const Text('Всегда светлая тема'),
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.setLight();
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Тёмная'),
              subtitle: const Text('Всегда тёмная тема'),
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.setDark();
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Системная'),
              subtitle: const Text('Автоматически от настроек устройства'),
              value: ThemeMode.system,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.setSystem();
                  Navigator.pop(context);
                }
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

  Widget _buildAdditionalOptions(BuildContext context) {
    final theme = Theme.of(context);

    final options = <Map<String, dynamic>>[
      {
        'icon': Icons.security_outlined,
        'label': 'Безопасность',
        'route': '/settings/security',
      },
      {
        'icon': Icons.privacy_tip_outlined,
        'label': 'Конфиденциальность',
        'route': '/settings/privacy',
      },
      {
        'icon': Icons.language_outlined,
        'label': 'Язык',
        'route': '/settings/language',
      },
      {
        'icon': Icons.info_outline,
        'label': 'О приложении',
        'route': '/settings/about',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.radiusXl,
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
            onTap: () => context.push(option['route'] as String),
            borderRadius: BorderRadius.vertical(
              top: index == 0
                  ? const Radius.circular(AppRadius.xl)
                  : Radius.zero,
              bottom: isLast
                  ? const Radius.circular(AppRadius.xl)
                  : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                      AppSpacing.sm + AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Icon(
                      option['icon'] as IconData,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Text(
                    option['label'] as String,
                    style: AppTypography.bodyLarge(context),
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

  Widget _buildLogoutButtonFromRef(BuildContext context, WidgetRef ref) {
    final sessionManager = ref.watch(sessionManagerProvider);
    return _buildLogoutButton(context, sessionManager);
  }

  Widget _buildLogoutButton(
    BuildContext context,
    SessionManager sessionManager,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: OutlinedButton.icon(
          onPressed: () => _showLogoutDialog(context, sessionManager),
          icon: const Icon(Icons.logout),
          label: const Text('Выйти из аккаунта'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(
              color: theme.colorScheme.error.withValues(alpha: 0.3),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, SessionManager sessionManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        icon: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.logout, color: AppColors.error, size: 32),
        ),
        title: const Text('Выйти из аккаунта?', textAlign: TextAlign.center),
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
              await sessionManager.signOut();
              if (context.mounted) context.go('/auth');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
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
