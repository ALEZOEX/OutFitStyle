import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../presentation/providers/repository_providers.dart';

// UseCase провайдеры для achievements будут добавлены позже
// Пока используем репозиторий напрямую

final achievementNotifierProvider =
    StateNotifierProvider<AchievementNotifier, AchievementNotifierState>(
  (ref) => AchievementNotifier(ref.watch(achievementRepositoryProvider)),
);

class AchievementNotifierState {
  final List<dynamic> achievements;
  final bool isLoading;
  final String? error;

  AchievementNotifierState({
    this.achievements = const [],
    this.isLoading = false,
    this.error,
  });
}

class AchievementNotifier extends StateNotifier<AchievementNotifierState> {
  final AchievementRepository _repository;

  AchievementNotifier(this._repository) : super(AchievementNotifierState());

  Future<void> loadAchievements() async {
    state = AchievementNotifierState(isLoading: true);
    try {
      final result = await _repository.getAchievements();
      result.fold(
        (error) => state = AchievementNotifierState(error: error),
        (achievements) =>
            state = AchievementNotifierState(achievements: achievements),
      );
    } catch (e) {
      state = AchievementNotifierState(error: e.toString());
    }
  }
}
