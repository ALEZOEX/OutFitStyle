import 'package:flutter/material.dart';
import '../../../../domain/entities/achievement.dart';

/// Карточка достижения с улучшенным UI
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;
  final bool showCategory;
  final bool animateUnlock;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
    this.showCategory = false,
    this.animateUnlock = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;
    final progressPercent = achievement.progressPercent;

    return Card(
      elevation: isUnlocked ? 4 : 2,
      shadowColor:
          isUnlocked ? theme.colorScheme.primary.withOpacity(0.3) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isUnlocked
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.1),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Иконка достижения
              _buildIconContainer(theme, isUnlocked),
              const SizedBox(width: 16),
              // Информация о достижении
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок и бейдж категории
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isUnlocked
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showCategory) ...[
                          const SizedBox(width: 8),
                          _buildCategoryBadge(theme),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Описание
                    Text(
                      achievement.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Прогресс бар
                    _buildProgressBar(theme, isUnlocked, progressPercent),
                    const SizedBox(height: 4),
                    // Текст прогресса и очки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          achievement.progressText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _buildPointsChip(theme),
                      ],
                    ),
                  ],
                ),
              ),
              // Статус разблокировки
              const SizedBox(width: 12),
              _buildStatusIcon(theme, isUnlocked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(ThemeData theme, bool isUnlocked) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient:
            isUnlocked
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primary.withOpacity(0.3),
                  ],
                )
                : null,
        color: isUnlocked ? null : theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isUnlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          achievement.icon,
          style: TextStyle(
            fontSize: 28,
            color: isUnlocked ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        achievement.categoryIcon,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildProgressBar(
    ThemeData theme,
    bool isUnlocked,
    double progressPercent,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: progressPercent / 100,
        backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(
          isUnlocked ? theme.colorScheme.primary : theme.colorScheme.secondary,
        ),
        minHeight: 6,
      ),
    );
  }

  Widget _buildPointsChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12, color: theme.colorScheme.tertiary),
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
    );
  }

  Widget _buildStatusIcon(ThemeData theme, bool isUnlocked) {
    if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: theme.colorScheme.onPrimaryContainer,
          size: 20,
        ),
      );
    } else {
      return Icon(
        Icons.lock_outline,
        color: theme.colorScheme.outline.withOpacity(0.5),
        size: 24,
      );
    }
  }
}
