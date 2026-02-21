import 'package:flutter/material.dart';

/// Виджет прогресс-бара достижения с анимацией
class AchievementProgress extends StatelessWidget {
  final double progress;
  final String? progressText;
  final bool isCompleted;
  final bool showPercentage;
  final double height;
  final Duration animationDuration;

  const AchievementProgress({
    super.key,
    required this.progress,
    this.progressText,
    this.isCompleted = false,
    this.showPercentage = true,
    this.height = 8,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedProgress = (progress / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Прогресс бар
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // Фон
                Container(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                // Прогресс
                AnimatedContainer(
                  duration: animationDuration,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        _getProgressColor(theme, clampedProgress),
                        _getProgressColor(theme, clampedProgress).withOpacity(0.7),
                      ],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * clampedProgress,
                ),
              ],
            ),
          ),
        ),
        // Текст прогресса
        if (showPercentage || progressText != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (progressText != null)
                Text(
                  progressText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (showPercentage)
                Text(
                  '${(progress).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getProgressColor(theme, clampedProgress),
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getProgressColor(ThemeData theme, double progress) {
    if (progress >= 1.0) {
      return theme.colorScheme.primary;
    } else if (progress >= 0.75) {
      return theme.colorScheme.tertiary;
    } else if (progress >= 0.5) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.outline;
    }
  }
}

/// Виджет кругового прогресс-индикатора для достижений
class CircularAchievementProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool showCheckmark;

  const CircularAchievementProgress({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.child,
    this.showCheckmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedProgress = (progress / 100).clamp(0.0, 1.0);
    final isCompleted = clampedProgress >= 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Фоновый круг
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          // Прогресс
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: clampedProgress),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                );
              },
            ),
          ),
          // Иконка или текст в центре
          if (showCheckmark && isCompleted)
            Icon(
              Icons.check,
              color: theme.colorScheme.primary,
              size: size * 0.4,
            )
          else if (child != null)
            child!,
        ],
      ),
    );
  }
}
