// achievements/presentation/controllers/achievement_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';

part 'achievement_controller.freezed.dart';

@freezed
class AchievementState with _$AchievementState {
  const factory AchievementState.initial() = _Initial;
  const factory AchievementState.loading() = _Loading;
  const factory AchievementState.loaded({
    required List<Achievement> achievements,
  }) = _Loaded;
  const factory AchievementState.error(String message) = _Error;
}

class AchievementController extends StateNotifier<AchievementState> {
  final AchievementRepository _repository;

  AchievementController(this._repository) : super(const AchievementState.initial());

  Future<void> loadAchievements() async {
    state = const AchievementState.loading();
    try {
      final achievements = await _repository.getUserAchievements();
      state = AchievementState.loaded(achievements: achievements);
    } catch (e) {
      state = AchievementState.error(e.toString());
    }
  }

  Future<void> updateAchievementProgress(String achievementId, int increment) async {
    try {
      await _repository.updateAchievementProgress(achievementId, increment);
      // Обновляем состояние
      await loadAchievements();
    } catch (e) {
      state = AchievementState.error('Failed to update achievement progress: $e');
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    try {
      await _repository.unlockAchievement(achievementId);
      // Обновляем состояние
      await loadAchievements();
    } catch (e) {
      state = AchievementState.error('Failed to unlock achievement: $e');
    }
  }
}