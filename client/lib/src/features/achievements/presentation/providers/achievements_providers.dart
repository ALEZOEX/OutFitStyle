import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/achievement.dart';

/// Mock данные для достижений
final mockAchievements = <Achievement>[
  const Achievement(
    id: 'first_item',
    title: 'Первый образ',
    description: 'Добавьте первую вещь в гардероб',
    icon: '🎯',
    category: 'starter',
    points: 10,
    isUnlocked: false,
    currentProgress: 0,
    targetValue: 1,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  const Achievement(
    id: 'collector',
    title: 'Коллекционер',
    description: 'Добавьте 10 вещей в гардероб',
    icon: '🏆',
    category: 'wardrobe',
    points: 50,
    isUnlocked: false,
    currentProgress: 0,
    targetValue: 10,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  const Achievement(
    id: 'stylish',
    title: 'Стильный',
    description: 'Получите 5 лайков за образы',
    icon: '⭐',
    category: 'social',
    points: 30,
    isUnlocked: false,
    currentProgress: 0,
    targetValue: 5,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  const Achievement(
    id: 'active',
    title: 'Активный',
    description: 'Заходите 7 дней подряд',
    icon: '🔥',
    category: 'activity',
    points: 100,
    isUnlocked: false,
    currentProgress: 0,
    targetValue: 7,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
  const Achievement(
    id: 'expert',
    title: 'Эксперт',
    description: 'Добавьте 50 вещей в гардероб',
    icon: '💎',
    category: 'wardrobe',
    points: 200,
    isUnlocked: false,
    currentProgress: 0,
    targetValue: 50,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  ),
];

/// Провайдер списка всех достижений
final allAchievementsProvider = Provider<List<Achievement>>((ref) {
  return mockAchievements;
});

/// State notifier для управления достижениями
class AchievementsNotifier extends StateNotifier<AchievementsState> {
  AchievementsNotifier() : super(const AchievementsState());

  /// Загрузить все достижения
  Future<void> loadAllAchievements() async {
    state = const AchievementsState(isLoading: true);
    try {
      // В будущем здесь будет загрузка с сервера
      await Future.delayed(const Duration(milliseconds: 500));
      state = AchievementsState(
        achievements: mockAchievements,
        isLoading: false,
      );
    } catch (e) {
      state = AchievementsState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Обновить прогресс достижения
  Future<void> updateAchievementProgress(String achievementId, int progress) async {
    final updated = state.achievements.map((a) {
      if (a.id == achievementId) {
        return a.copyWith(
          currentProgress: progress,
          isUnlocked: progress >= a.targetValue,
        );
      }
      return a;
    }).toList();
    
    state = state.copyWith(achievements: updated);
  }
}

/// Провайдер notifier
final achievementsNotifierProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  return AchievementsNotifier();
});

/// Состояние достижений
class AchievementsState {
  final List<Achievement> achievements;
  final bool isLoading;
  final String? error;

  const AchievementsState({
    this.achievements = const [],
    this.isLoading = false,
    this.error,
  });

  AchievementsState copyWith({
    List<Achievement>? achievements,
    bool? isLoading,
    String? error,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
