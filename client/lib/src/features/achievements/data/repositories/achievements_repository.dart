import 'package:dartz/dartz.dart';
import '../../../core/api/api_client.dart';
import '../../entities/achievement.dart';
import '../../entities/achievement_progress.dart';
import '../../entities/user_achievement_status.dart';
import '../../enums/achievement_status.dart';

/// Репозиторий для работы с достижениями пользователя
/// 
/// Взаимодействует с API эндпоинтами:
/// - GET /api/v1/achievements - список всех достижений
/// - GET /api/v1/achievements/my - достижения пользователя с прогрессом
/// - GET /api/v1/achievements/progress - прогресс пользователя
class AchievementsRepository implements AchievementRepository {
  final ApiClient _apiClient;

  AchievementsRepository({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Получить все доступные достижения
  /// 
  /// Endpoint: GET /api/v1/achievements
  @override
  Future<Either<String, List<Achievement>>> getAchievements() async {
    try {
      final response = await _apiClient.get('/api/v1/achievements');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final achievementsData = data['achievements'] as List<dynamic>? ?? [];
        
        final achievements = achievementsData
            .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return Right(achievements);
      } else {
        return Left('Ошибка получения достижений: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return Left(_handleError(e));
    } catch (e) {
      return Left('Ошибка получения достижений: $e');
    }
  }

  /// Получить достижения пользователя с прогрессом
  /// 
  /// Endpoint: GET /api/v1/achievements/my
  Future<AchievementsMyResult> getMyAchievements() async {
    try {
      final response = await _apiClient.get('/api/v1/achievements/my');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        final unlocked = (data['unlocked'] as List<dynamic>?)
                ?.map((item) => Achievement.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        
        final inProgress = (data['in_progress'] as List<dynamic>?)
                ?.map((item) => Achievement.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        
        final totalPoints = data['total_points'] as int? ?? 0;
        final rank = data['rank'] as String? ?? 'Новичок';
        
        return AchievementsMyResult(
          unlocked: unlocked,
          inProgress: inProgress,
          totalPoints: totalPoints,
          rank: rank,
        );
      } else {
        throw AchievementsException('Ошибка получения достижений: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is AchievementsException) rethrow;
      throw AchievementsException('Ошибка получения достижений: $e');
    }
  }

  /// Получить прогресс достижений пользователя
  /// 
  /// Endpoint: GET /api/v1/achievements/progress
  Future<List<AchievementProgress>> getAchievementsProgress() async {
    try {
      final response = await _apiClient.get('/api/v1/achievements/progress');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final progressData = data['progress'] as List<dynamic>? ?? [];
        
        return progressData
            .map((item) => AchievementProgress.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw AchievementsException('Ошибка получения прогресса: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is AchievementsException) rethrow;
      throw AchievementsException('Ошибка получения прогресса: $e');
    }
  }

  // Реализация методов из абстрактного класса
  
  @override
  Future<Either<String, List<Achievement>>> getAllAchievements() {
    return getAchievements();
  }

  @override
  Future<Either<String, List<AchievementProgress>>> getUserAchievements(int userId) {
    // Этот метод используется для обратной совместимости
    // В новой версии используем getMyAchievements()
    throw UnimplementedError('Используйте getMyAchievements() вместо этого метода');
  }

  @override
  Future<Either<String, AchievementProgress>> updateUserAchievement({
    required int userId,
    required int achievementId,
    required int progress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, AchievementProgress>> unlockAchievement({
    required int userId,
    required int achievementId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, List<UserAchievementStatus>>> getUserAchievementStatus(int userId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, UserAchievementStatus>> setUserAchievementStatus({
    required int userId,
    required int achievementId,
    required AchievementStatus status,
    int? progress,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, AchievementProgress>> incrementUserAchievementProgress({
    required int userId,
    required int achievementId,
    int incrementBy = 1,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, List<Achievement>>> getUserUnlockedAchievements(int userId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, List<Achievement>>> getUserLockedAchievements(int userId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, List<Achievement>>> getUserInProgressAchievements(int userId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, AchievementProgress>> getAchievementProgress({
    required int userId,
    required int achievementId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, void>> resetAchievementProgress({
    required int userId,
    required int achievementId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<String, void>> awardAchievementReward({
    required int userId,
    required int achievementId,
  }) {
    throw UnimplementedError();
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Превышено время ожидания. Проверьте соединение.';
    }
    
    if (e.type == DioExceptionType.connectionError) {
      return 'Нет соединения с интернетом.';
    }
    
    return 'Ошибка сети: ${e.message}';
  }

  void _handleDioError(DioException e) {
    final message = _handleError(e);
    throw AchievementsException(message);
  }
}

/// Результат получения достижений пользователя
class AchievementsMyResult {
  final List<Achievement> unlocked;
  final List<Achievement> inProgress;
  final int totalPoints;
  final String rank;

  AchievementsMyResult({
    required this.unlocked,
    required this.inProgress,
    required this.totalPoints,
    required this.rank,
  });
}

/// Исключение репозитория достижений
class AchievementsException implements Exception {
  final String message;
  
  const AchievementsException(this.message);
  
  @override
  String toString() => 'AchievementsException: $message';
}
