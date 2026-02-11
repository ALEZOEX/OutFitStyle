import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/achievement.dart';
import '../providers/achievement_provider.dart';
import 'achievement_card_widget.dart';

class AchievementListWidget extends ConsumerWidget {
  final List<Achievement> achievements;
  final String? userId;

  const AchievementListWidget({
    Key? key,
    required this.achievements,
    this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];

        return AchievementCardWidget(
          achievement: achievement,
          onTap: userId != null
              ? () {
                  // При нажатии можно увеличить прогресс ачивки (для демонстрации)
                  // В реальном приложении это будет зависеть от типа ачивки
                  ref
                      .read(achievementNotifierProvider.notifier)
                      .updateUserAchievement(userId!, achievement.id);
                }
              : null,
        );
      },
    );
  }
}
