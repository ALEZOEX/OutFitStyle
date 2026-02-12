import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../../../domain/entities/achievement.dart';
import '../../../../domain/entities/achievement_progress.dart';
import '../domain/usecases/get_all_achievements_usecase.dart';
import '../domain/usecases/get_user_achievements_usecase.dart';
import '../domain/usecases/update_user_achievement_usecase.dart';
import '../domain/usecases/unlock_achievement_usecase.dart';
import 'services/achievement_notification_service.dart';

class AchievementNotifier extends StateNotifier<AchievementState> {
  final GetAllAchievementsUseCase _getAllAchievementsUseCase;
  final GetUserAchievementsUseCase _getUserAchievementsUseCase;
  final UpdateUserAchievementUseCase _updateUserAchievementUseCase;
  final UnlockAchievementUseCase _unlockAchievementUseCase;
  final AchievementNotificationService _notificationService;

  AchievementNotifier({
    required GetAllAchievementsUseCase getAllAchievementsUseCase,
    required GetUserAchievementsUseCase getUserAchievementsUseCase,
    required UpdateUserAchievementUseCase updateUserAchievementUseCase,
    required UnlockAchievementUseCase unlockAchievementUseCase,
    required AchievementNotificationService notificationService,
  })  : _getAllAchievementsUseCase = getAllAchievementsUseCase,
        _getUserAchievementsUseCase = getUserAchievementsUseCase,
        _updateUserAchievementUseCase = updateUserAchievementUseCase,
        _unlockAchievementUseCase = unlockAchievementUseCase,
        _notificationService = notificationService,
        super(const AchievementState.initial());

  Future<void> loadAllAchievements() async {
    state = const AchievementState.loading();

    final result = await _getAllAchievementsUseCase.call();

    result.fold(
      (failure) => state = AchievementState.error(failure),
      (achievements) => state = AchievementState.loaded(achievements),
    );
  }

  Future<void> loadUserAchievements(String userId) async {
    state = const AchievementState.loading();

    final result = await _getUserAchievementsUseCase.call(userId);

    result.fold(
      (failure) => state = AchievementState.error(failure),
      (progress) => state = AchievementState.userLoaded(progress),
    );
  }

  Future<void> updateUserAchievement(String userId, String achievementId,
      {int progressIncrement = 1}) async {
    final result = await _updateUserAchievementUseCase.call(
        userId, achievementId, progressIncrement);

    result.fold(
      (failure) => state = AchievementState.error(failure),
      (success) {
        // После успешного обновления прогресса проверяем, была ли разблокирована ачивка
        // и показываем всплывающее уведомление
        _checkAndShowUnlockNotification(userId, achievementId);
      },
    );
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    final result = await _unlockAchievementUseCase.call(userId, achievementId);

    result.fold(
      (failure) => state = AchievementState.error(failure),
      (success) async {
        // После успешной разблокировки проверяем и показываем уведомление
        await _checkAndShowUnlockNotification(userId, achievementId);
      }, // Ачивка разблокирована
    );
  }

  // Внутренний метод для проверки и показа уведомления о разблокировке
  Future<void> _checkAndShowUnlockNotification(
      String userId, String achievementId) async {
    final result = await _getUserAchievementsUseCase.call(userId);

    result.fold(
      (failure) => {},
      (progress) async {
        final achievementStatus = progress.achievements[achievementId];
        if (achievementStatus != null && achievementStatus.isUnlocked) {
          // Найти информацию об ачивке для уведомления
          final achievement = getAchievementById(achievementId);
          if (achievement != null) {
            // Обновляем информацию об ачивке с текущим прогрессом
            final updatedAchievement = achievement.copyWith(
              currentProgress: achievementStatus.currentProgress,
              isUnlocked: achievementStatus.isUnlocked,
              unlockedAt: achievementStatus.unlockedAt,
            );

            // Показываем уведомление
            _showUnlockNotification(updatedAchievement);
          }
        }
      },
    );
  }

  // Внутренний метод для показа уведомления о разблокировке
  void _showUnlockNotification(Achievement achievement) {
    // Показываем уведомление через сервис
    debugPrint(
        'Подготовка к показу уведомления о разблокировке ачивки: ${achievement.title}');
  }

  // Метод для показа всплывающего уведомления в UI
  void showInAppNotification(BuildContext context, Achievement achievement) {
    _notificationService.showInAppAchievementNotification(context, achievement);
  }

  // Метод для получения информации об определенной ачивке
  Achievement? getAchievementById(String achievementId) {
    if (state.achievements != null) {
      return state.achievements!
          .firstWhere((a) => a.id == achievementId, orElse: () => null);
    }
    return null;
  }
}

class AchievementState {
  final AchievementStatus status;
  final List<Achievement>? achievements;
  final AchievementProgress? userProgress;
  final String? errorMessage;

  const AchievementState._({
    required this.status,
    this.achievements,
    this.userProgress,
    this.errorMessage,
  });

  const AchievementState.initial()
      : status = AchievementStatus.initial,
        achievements = null,
        userProgress = null,
        errorMessage = null;

  const AchievementState.loading()
      : status = AchievementStatus.loading,
        achievements = null,
        userProgress = null,
        errorMessage = null;

  AchievementState.loaded(List<Achievement> achievements)
      : status = AchievementStatus.loaded,
        achievements = achievements,
        userProgress = null,
        errorMessage = null;

  AchievementState.userLoaded(AchievementProgress userProgress)
      : status = AchievementStatus.userLoaded,
        achievements = null,
        userProgress = userProgress,
        errorMessage = null;

  AchievementState.error(String message)
      : status = AchievementStatus.error,
        achievements = null,
        userProgress = null,
        errorMessage = message;
}

enum AchievementStatus {
  initial,
  loading,
  loaded,
  userLoaded,
  error,
}
