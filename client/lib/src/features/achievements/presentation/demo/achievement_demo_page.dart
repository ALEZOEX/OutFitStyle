import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../src/features/achievements/feature_exports.dart';

/// Простой пример использования системы ачивок
class AchievementDemoPage extends ConsumerWidget {
  const AchievementDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Демонстрация ачивок'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Загружаем ачивки
              ref
                  .read(achievementNotifierProvider.notifier)
                  .loadAllAchievements();
            },
            child: const Text('Загрузить ачивки'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Пример показа уведомления
              final sampleAchievement = Achievement(
                id: 'demo_achievement',
                title: 'Демо-ачивка',
                description: 'Это демонстрационная ачивка',
                iconPath: 'assets/icons/achievement_demo.png',
                type: AchievementType.outfitCreated,
                targetProgress: 1,
                currentProgress: 1,
                isUnlocked: true,
                unlockedAt: DateTime.now(),
              );

              ref
                  .read(achievementNotifierProvider.notifier)
                  .showInAppNotification(context, sampleAchievement);
            },
            child: const Text('Показать уведомление'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(achievementNotifierProvider);

                return switch (state.status) {
                  AchievementStatus.initial ||
                  AchievementStatus.loading =>
                    const Center(child: CircularProgressIndicator()),
                  AchievementStatus.loaded => state.achievements != null
                      ? AchievementListWidget(achievements: state.achievements!)
                      : const Center(child: Text('Нет данных')),
                  AchievementStatus.userLoaded => state.userProgress != null
                      ? AchievementListWidget(
                          achievements: [], // Здесь нужно правильно отобразить ачивки пользователя
                          userId: state.userProgress!.userId,
                        )
                      : const Center(child: Text('Нет данных')),
                  AchievementStatus.error =>
                    Center(child: Text('Ошибка: ${state.errorMessage}')),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
