import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../services/auth_storage.dart';
import '../../data/repositories/achievements_repository.dart';

/// Провайдер для AuthStorage
final _authStorageProvider = Provider<AuthStorage>((ref) {
  throw UnimplementedError('AuthStorage должен быть предоставлен');
});

/// Провайдер для ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(_authStorageProvider);
  return ApiClient(storage: storage);
});

/// Провайдер репозитория достижений
final achievementsRepositoryProvider = Provider<AchievementsRepository>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return AchievementsRepository(apiClient: apiClient);
});

/// Провайдер для загрузки всех достижений
final allAchievementsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(achievementsRepositoryProvider);
  final result = await repository.getAchievements();
  return result.fold(
    (error) => throw Exception(error),
    (achievements) => achievements,
  );
});

/// Провайдер для загрузки достижений пользователя
final myAchievementsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(achievementsRepositoryProvider);
  return repository.getMyAchievements();
});

/// State notifier для управления достижениями
class AchievementsNotifier extends StateNotifier<AchievementsState> {
  final AchievementsRepository _repository;

  AchievementsNotifier(this._repository) : super(const AchievementsState());

  /// Загрузить достижения пользователя
  Future<void> loadMyAchievements() async {
    state = const AchievementsState(isLoading: true);
    try {
      final result = await _repository.getMyAchievements();
      state = AchievementsState(
        unlocked: result.unlocked,
        inProgress: result.inProgress,
        totalPoints: result.totalPoints,
        rank: result.rank,
      );
    } catch (e) {
      state = AchievementsState(error: e.toString());
    }
  }
}

/// Состояние достижений
class AchievementsState {
  final List<dynamic> unlocked;
  final List<dynamic> inProgress;
  final int totalPoints;
  final String rank;
  final bool isLoading;
  final String? error;

  const AchievementsState({
    this.unlocked = const [],
    this.inProgress = const [],
    this.totalPoints = 0,
    this.rank = 'Новичок',
    this.isLoading = false,
    this.error,
  });
}

/// Провайдер notifier для достижений
final achievementsNotifierProvider = StateNotifierProvider<AchievementsNotifier, AchievementsState>((ref) {
  final repository = ref.watch(achievementsRepositoryProvider);
  return AchievementsNotifier(repository);
});
