import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../../domain/entities/achievement.dart';

/// Сервис для отображения уведомлений о разблокировке достижений
class AchievementNotificationService {
  /// Показать in-app уведомление о разблокировке достижения
  static void showInAppNotification(
    BuildContext context,
    Achievement achievement, {
    VoidCallback? onTap,
  }) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final messengerState = ScaffoldMessenger.maybeOf(context);

    if (messengerState == null) return;

    messengerState.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          // Иконка достижения с градиентом
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              achievement.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          // Текст уведомления
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: theme.colorScheme.tertiary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Достижение разблокировано!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onInverseSurface.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '+${achievement.points} очков',
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
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 8,
      backgroundColor: theme.colorScheme.inverseSurface,
    );

    messengerState.showSnackBar(snackBar);

    // Вызов callback при нажатии
    if (onTap != null) {
      // Обработка нажатия на уведомление
      snackBar.action = SnackBarAction(
        label: 'Открыть',
        textColor: theme.colorScheme.primary,
        onPressed: onTap,
      );
    }
  }

  /// Показать диалог разблокировки достижения
  static void showUnlockDialog(
    BuildContext context,
    Achievement achievement, {
    VoidCallback? onDismiss,
  }) {
    if (!context.mounted) return;

    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 16,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                  theme.colorScheme.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Анимированная иконка
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Заголовок
                Text(
                  '🎉 Достижение разблокировано!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Название достижения
                Text(
                  achievement.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Описание
                Text(
                  achievement.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Награда
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: theme.colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${achievement.points} очков',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Кнопка
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      onDismiss?.call();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Продолжить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Воспроизвести эффект конфетти
  static void playConfetti(ConfettiController controller) {
    controller.play();
    // Остановить через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      controller.stop();
    });
  }
}

/// Провайдер для управления уведомлениями о достижениях
final achievementNotificationControllerProvider = Provider<ConfettiController>((ref) {
  final controller = ConfettiController(duration: const Duration(seconds: 3));
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Виджет обертки для отображения конфетти при разблокировке достижений
class AchievementConfettiOverlay extends ConsumerWidget {
  final Widget child;
  final List<Achievement> newlyUnlocked;

  const AchievementConfettiOverlay({
    super.key,
    required this.child,
    this.newlyUnlocked = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final confettiController = ref.watch(achievementNotificationControllerProvider);

    // Слушаем новые разблокированные достижения
    ref.listen<List<Achievement>>(
      newlyUnlockedAchievementsProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          AchievementNotificationService.playConfetti(confettiController);
        }
      },
    );

    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.orange,
              Colors.purple,
              Colors.pink,
              Colors.red,
            ],
          ),
        ),
      ],
    );
  }
}

/// Провайдер для отслеживания только что разблокированных достижений
final newlyUnlockedAchievementsProvider = StateProvider<List<Achievement>>((ref) => []);
