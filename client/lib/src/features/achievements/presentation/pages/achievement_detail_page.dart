import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../domain/entities/achievement.dart';
import '../providers/achievements_providers.dart';
import '../widgets/achievement_icon.dart';
import '../widgets/achievement_progress.dart';
import '../widgets/achievement_badge.dart';

/// Страница деталей достижения
class AchievementDetailPage extends ConsumerWidget {
  final String achievementId;

  const AchievementDetailPage({super.key, required this.achievementId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final achievement = ref
        .read(achievementsNotifierProvider.notifier)
        .getAchievementById(achievementId);

    if (achievement == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Достижение не найдено')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Достижение не найдено',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar с кнопкой назад
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
              tooltip: 'Назад',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareAchievement(context, achievement),
                tooltip: 'Поделиться',
              ),
            ],
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(context, achievement),
            ),
          ),
          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и категория
                  _buildTitleSection(context, achievement),
                  const SizedBox(height: 24),
                  // Описание
                  _buildDescriptionSection(context, achievement),
                  const SizedBox(height: 24),
                  // Прогресс
                  _buildProgressSection(context, achievement),
                  const SizedBox(height: 24),
                  // Награда
                  _buildRewardSection(context, achievement),
                  const SizedBox(height: 24),
                  // Статус разблокировки
                  _buildStatusSection(context, achievement),
                  const SizedBox(height: 32),
                  // Кнопки действий
                  _buildActionButtons(context, ref, achievement),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Center(
        child: AchievementIcon(achievement: achievement, size: 100),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                achievement.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (achievement.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Разблокировано',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CategoryBadge(
              categoryName: achievement.categoryDisplayName,
              icon: achievement.categoryIcon,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.points}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    Achievement achievement,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Описание',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up,
              color: theme.colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Прогресс',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CircularAchievementProgress(
          progress: achievement.progressPercent,
          size: 120,
          strokeWidth: 10,
          showCheckmark: achievement.isUnlocked,
        ),
        const SizedBox(height: 16),
        AchievementProgress(
          progress: achievement.progressPercent,
          progressText: achievement.progressText,
          isCompleted: achievement.isUnlocked,
          showPercentage: false,
          height: 10,
        ),
      ],
    );
  }

  Widget _buildRewardSection(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: theme.colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Награда',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                Text(
                  '${achievement.points} очков',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);

    if (achievement.isUnlocked && achievement.unlockedAt != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.event, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Разблокировано',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  _formatDateTime(achievement.unlockedAt!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 
                      0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lock_outline,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              'Достижение еще не разблокировано',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    Achievement achievement,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (!achievement.isUnlocked)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                // Для демонстрации - увеличить прогресс
                ref
                    .read(achievementsNotifierProvider.notifier)
                    .incrementAchievementProgress(achievementId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Прогресс увеличен: ${achievement.progressText}',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Увеличить прогресс (демо)'),
            ),
          ),
        if (!achievement.isUnlocked) const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _shareAchievement(context, achievement),
            icon: const Icon(Icons.share),
            label: const Text('Поделиться достижением'),
          ),
        ),
      ],
    );
  }

  Future<void> _shareAchievement(
    BuildContext context,
    Achievement achievement,
  ) async {
    // Формируем текст для шеринга
    final shareText = '''
🏆 Достижение разблокировано!

${achievement.title}

${achievement.description}

Награда: ${achievement.points} очков
Прогресс: ${achievement.progressText}

#OutfitStyle #Достижения
''';

    try {
      await Share.share(
        shareText,
        subject: 'Моё достижение в OutfitStyle: ${achievement.title}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка шеринга: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Сегодня в ${_formatTime(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Вчера в ${_formatTime(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
