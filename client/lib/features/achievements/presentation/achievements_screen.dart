import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Заглушка для достижений
    final achievements = [
      const _AchievementItem(
        icon: '👕',
        title: 'Первая вещь',
        description: 'Добавил первую вещь в гардероб',
        unlocked: true,
      ),
      const _AchievementItem(
        icon: '👗',
        title: 'Коллекционер',
        description: 'Добавил 10 вещей в гардероб',
        unlocked: false,
      ),
      const _AchievementItem(
        icon: '👔',
        title: 'Стиляга',
        description: 'Создал 5 образов',
        unlocked: false,
      ),
      const _AchievementItem(
        icon: '👟',
        title: 'Исследователь',
        description: 'Попробовал все категории',
        unlocked: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Твои успехи',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...achievements,
        ],
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final bool unlocked;

  const _AchievementItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: unlocked
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 28,
                    color: unlocked ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: unlocked ? null : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: unlocked
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            if (unlocked)
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}