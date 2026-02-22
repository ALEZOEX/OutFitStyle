import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_config.dart';
import '../models/achievement_dto.dart';

/// API сервис для работы с достижениями
class AchievementsApiService {
  final ApiClient _apiClient;

  AchievementsApiService(this._apiClient);

  /// Получить все доступные достижения в системе
  Future<AchievementsResponse> getAllAchievements() async {
    final response = await _apiClient.get('/api/v1/achievements');
    final data = response.data as Map<String, dynamic>;
    return AchievementsResponse.fromJson(data);
  }

  /// Получить достижения текущего пользователя
  Future<UserAchievementsResponse> getMyAchievements() async {
    final response = await _apiClient.get('/api/v1/achievements/my');
    final data = response.data as Map<String, dynamic>;
    return UserAchievementsResponse.fromJson(data);
  }

  /// Обработать событие для обновления прогресса достижения
  /// Возвращает список только что разблокированных достижений
  Future<List<AchievementDto>> trackEvent({
    required String eventType,
    int value = 1,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/achievements/track',
        data: {
          'event_type': eventType,
          'value': value,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final newlyUnlocked = data['newly_unlocked'] as List? ?? [];

      return newlyUnlocked
          .map((item) => AchievementDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Если эндпоинт еще не реализован, возвращаем пустой список
      if (e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }

  /// Получить прогресс конкретного достижения пользователя
  Future<AchievementProgressDto> getAchievementProgress(String achievementId) async {
    final response = await _apiClient.get(
      '/api/v1/achievements/$achievementId/progress',
    );
    final data = response.data as Map<String, dynamic>;
    return AchievementProgressDto.fromJson(data);
  }

  /// Сбросить прогресс достижения (для тестирования)
  Future<void> resetAchievementProgress(String achievementId) async {
    await _apiClient.delete(
      '/api/v1/achievements/$achievementId/progress',
    );
  }

  /// Разблокировать достижение по ID
  Future<Either<String, AchievementProgressDto>> unlockAchievementById(int achievementId) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/achievements/$achievementId/unlock',
      );
      final data = response.data as Map<String, dynamic>;
      final progress = AchievementProgressDto.fromJson(data);

      return right(progress);
    } on DioException catch (e) {
      return left(e.response?.data?['message'] as String? ?? 'Failed to unlock achievement');
    }
  }
}

/// DTO прогресса достижения
class AchievementProgressDto {
  final String achievementId;
  final int current;
  final int target;
  final bool isCompleted;
  final DateTime? updatedAt;

  AchievementProgressDto({
    required this.achievementId,
    required this.current,
    required this.target,
    required this.isCompleted,
    this.updatedAt,
  });

  factory AchievementProgressDto.fromJson(Map<String, dynamic> json) {
    return AchievementProgressDto(
      achievementId: json['achievement_id'] as String,
      current: json['current'] as int,
      target: json['target'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
