import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/achievement.dart';
import '../providers/achievement_provider.dart';
import '../widgets/achievement_card.dart';

class AchievementsPage extends ConsumerStatefulWidget {
  const AchievementsPage({super.key});

  @override
  ConsumerState<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends ConsumerState<AchievementsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementNotifierProvider);
    final notifier = ref.read(achievementNotifierProvider.notifier);
    final theme = Theme.of(context);

    // Загружаем ачивки при первом открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.status == AchievementStatus.initial) {
        notifier.loadAllAchievements();
      }
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          // Контент
          switch (state.status) {
            AchievementStatus.initial ||
            AchievementStatus.loading =>
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            AchievementStatus.loaded => state.achievements != null
                ? _buildAchievementsList(context, state.achievements!)
                : SliverFillRemaining(
                    child: _buildErrorState(context, 'Данные недоступны'),
                  ),
            AchievementStatus.userLoaded => state.userProgress != null
                ? _buildAchievementsList(
                    context,
                    _mapUserProgressToAchievements(
                      state.achievements ?? [],
                      state.userProgress!,
                    ),
                  )
                : SliverFillRemaining(
                    child: _buildErrorState(context, 'Данные недоступны'),
                  ),
            AchievementStatus.error => SliverFillRemaining(
                child: _buildErrorState(context, state.errorMessage ?? 'Произошла ошибка'),
              ),
          },
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Достижения',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Открывайте новые достижения',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(achievementNotifierProvider.notifier).loadAllAchievements(),
              tooltip: 'Обновить',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context, List<Achievement> achievements) {
    final unlockedCount = achievements.where((a) => a.isUnlocked == true).length;
    final totalCount = achievements.length;
    final totalProgress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Общий прогресс
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Общий прогресс',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$unlockedCount/$totalCount',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: totalProgress,
                      backgroundColor: theme.colorScheme.outline.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(totalProgress * 100).toInt()}% разблокировано',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Список достижений
          ...achievements.map((achievement) => FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AchievementCard(
                achievement: achievement,
              ),
            ),
          )),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => ref.read(achievementNotifierProvider.notifier).loadAllAchievements(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить попытку'),
            ),
          ],
        ),
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
