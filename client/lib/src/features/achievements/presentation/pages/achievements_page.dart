import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/achievement.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement_list_widget.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementNotifierProvider);
    final notifier = ref.read(achievementNotifierProvider.notifier);

    // Загружаем ачивки при первом открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.status == AchievementStatus.initial) {
        notifier.loadAllAchievements();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          notifier.loadAllAchievements();
        },
        child: switch (state.status) {
          AchievementStatus.initial ||
          AchievementStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          AchievementStatus.loaded => state.achievements != null
              ? AchievementListWidget(achievements: state.achievements!)
              : const Center(child: Text('Ошибка: данные недоступны')),
          AchievementStatus.userLoaded => state.userProgress != null
              ? AchievementListWidget(
                  achievements: _mapUserProgressToAchievements(
                    state.achievements ?? [],
                    state.userProgress!,
                  ),
                  userId: state.userProgress!.userId,
                )
              : const Center(child: Text('Ошибка: данные недоступны')),
          AchievementStatus.error => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Произошла ошибка',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.loadAllAchievements(),
                    child: const Text('Повторить попытку'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }

  List<Achievement> _mapUserProgressToAchievements(
    List<Achievement> allAchievements,
    AchievementProgress userProgress,
  ) {
    return allAchievements.map((achievement) {
      final userStatus = userProgress.achievements[achievement.id];
      if (userStatus != null) {
        return achievement.copyWith(
          currentProgress: userStatus.currentProgress,
          isUnlocked: userStatus.isUnlocked,
          unlockedAt: userStatus.unlockedAt,
        );
      }
      return achievement;
    }).toList();
  }
}
