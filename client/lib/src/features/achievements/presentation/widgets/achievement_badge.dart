import 'package:flutter/material.dart';
import '../../../../domain/entities/achievement.dart';

/// Виджет бейджа для разблокированных достижений
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool showPoints;
  final bool showUnlockedDate;
  final Size size;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showPoints = true,
    this.showUnlockedDate = false,
    this.size = Size.small,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient:
            isUnlocked
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primaryContainer.withOpacity(0.5),
                  ],
                )
                : null,
        color: isUnlocked ? null : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isUnlocked
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Иконка
          Text(
            achievement.icon,
            style: TextStyle(fontSize: _iconSizeForSize(size)),
          ),
          const SizedBox(width: 8),
          // Название
          Text(
            achievement.title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  isUnlocked
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          // Очки
          if (showPoints) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 10, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 2),
                  Text(
                    '+${achievement.points}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _iconSizeForSize(Size size) {
    switch (size) {
      case Size.small:
        return 16;
      case Size.medium:
        return 20;
      case Size.large:
        return 24;
    }
  }
}

enum Size { small, medium, large }

/// Виджет бейджа категории
class CategoryBadge extends StatelessWidget {
  final String categoryName;
  final String icon;
  final int progress;
  final int total;

  const CategoryBadge({
    super.key,
    required this.categoryName,
    required this.icon,
    this.progress = 0,
    this.total = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = total > 0 ? (progress / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            categoryName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          if (total > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$progress/$total',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Виджет бейджа ранга пользователя
class RankBadge extends StatelessWidget {
  final String rank;
  final int totalPoints;

  const RankBadge({super.key, required this.rank, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rankData = _getRankData(rank);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [rankData.color, rankData.color.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rankData.color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(rankData.icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            rankData.displayName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$totalPoints очков',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  _RankData _getRankData(String rank) {
    switch (rank.toLowerCase()) {
      case 'platinum':
        return const _RankData(
          displayName: 'Платина',
          color: Color(0xFFE5E4E2),
          icon: Icons.diamond,
        );
      case 'gold':
        return const _RankData(
          displayName: 'Золото',
          color: Color(0xFFFFD700),
          icon: Icons.emoji_events,
        );
      case 'silver':
        return const _RankData(
          displayName: 'Серебро',
          color: Color(0xFFC0C0C0),
          icon: Icons.stars,
        );
      case 'bronze':
      default:
        return const _RankData(
          displayName: 'Бронза',
          color: Color(0xFFCD7F32),
          icon: Icons.local_fire_department,
        );
    }
  }
}

class _RankData {
  final String displayName;
  final Color color;
  final IconData icon;

  const _RankData({
    required this.displayName,
    required this.color,
    required this.icon,
  });
}
