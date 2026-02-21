import 'package:flutter/material.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_category.dart';

/// Виджет иконки достижения с градиентом и анимацией
class AchievementIcon extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final bool showUnlockedBorder;
  final bool animate;

  const AchievementIcon({
    super.key,
    required this.achievement,
    this.size = 60,
    this.showUnlockedBorder = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getGradientColor(theme, achievement.category),
                  _getGradientColor(theme, achievement.category).withOpacity(0.6),
                ],
              )
            : null,
        color: isUnlocked
            ? null
            : theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: showUnlockedBorder
            ? Border.all(
                color: isUnlocked
                    ? _getGradientColor(theme, achievement.category)
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: isUnlocked ? 3 : 1,
              )
            : null,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: _getGradientColor(theme, achievement.category)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          achievement.icon,
          style: TextStyle(
            fontSize: size * 0.5,
            color: isUnlocked ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Color _getGradientColor(ThemeData theme, AchievementCategory category) {
    switch (category) {
      case AchievementCategory.starter:
        return Colors.orange;
      case AchievementCategory.wardrobe:
        return Colors.blue;
      case AchievementCategory.recommendations:
        return Colors.purple;
      case AchievementCategory.weather:
        return Colors.cyan;
      case AchievementCategory.time:
        return Colors.green;
      case AchievementCategory.planning:
        return Colors.indigo;
      case AchievementCategory.ratings:
        return Colors.amber;
      case AchievementCategory.family:
        return Colors.pink;
      case AchievementCategory.special:
        return Colors.deepPurple;
    }
  }
}

/// Виджет иконки категории достижения
class CategoryIcon extends StatelessWidget {
  final AchievementCategory category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getCategoryColor(category),
            _getCategoryColor(category).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          category.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.starter:
        return Colors.orange;
      case AchievementCategory.wardrobe:
        return Colors.blue;
      case AchievementCategory.recommendations:
        return Colors.purple;
      case AchievementCategory.weather:
        return Colors.cyan;
      case AchievementCategory.time:
        return Colors.green;
      case AchievementCategory.planning:
        return Colors.indigo;
      case AchievementCategory.ratings:
        return Colors.amber;
      case AchievementCategory.family:
        return Colors.pink;
      case AchievementCategory.special:
        return Colors.deepPurple;
    }
  }
}
