import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/achievement_controller.dart';
import '../domain/entities/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  final String userId;

  const AchievementsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementControllerProvider);
    final controller = ref.read(achievementControllerProvider.notifier);

    // Load achievements when the screen is first displayed
    ref.listen(achievementControllerProvider.select((state) => state.loadingState), (previous, next) {
      if (previous == AchievementLoadingState.initial && next == AchievementLoadingState.initial) {
        controller.loadUserAchievements(userId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
      ),
      body: switch (state.loadingState) {
        AchievementLoadingState.initial || AchievementLoadingState.loading => const _LoadingWidget(),
        AchievementLoadingState.success => _AchievementsList(achievements: state.achievements),
        AchievementLoadingState.error => _ErrorWidget(message: state.errorMessage ?? 'Ошибка загрузки достижений'),
      },
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
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
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry logic would go here
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'У вас пока нет достижений',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementCard(achievement: achievement);
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: achievement.isUnlocked ? Colors.green : Colors.grey,
          child: Icon(
            Icons.emoji_events,
            color: achievement.isUnlocked ? Colors.white : Colors.white30,
          ),
        ),
        title: Text(achievement.title),
        subtitle: Text(achievement.description),
        trailing: achievement.isUnlocked
            ? const Icon(Icons.lock_open, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }
}