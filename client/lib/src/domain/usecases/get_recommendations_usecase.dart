import 'package:dartz/dartz.dart';
import '../entities/recommendation.dart';
import '../entities/weather_data.dart';
import '../repositories/recommendation_repository.dart';

/// UseCase для получения рекомендаций образов
class GetRecommendationsUseCase {
  final RecommendationRepository _repository;

  GetRecommendationsUseCase(this._repository);

  /// Получить рекомендации для пользователя
  Future<Either<String, List<Recommendation>>> call({
    required String userId,
    double? latitude,
    double? longitude,
    String? occasion,
    Map<String, dynamic> userPreferences = const {},
    int limit = 10,
  }) async {
    final weather = WeatherData(latitude: latitude, longitude: longitude);

    // Если указан повод — фильтруем по нему
    if (occasion != null && occasion.isNotEmpty) {
      return await _repository.getRecommendationsByOccasion(
        userId: userId,
        occasion: occasion,
        weather: weather,
      );
    }

    // Если есть координаты, но нет предпочтений — по погоде
    if (latitude != null && longitude != null && userPreferences.isEmpty) {
      return await _repository.getRecommendationsByWeather(
        userId: userId,
        weather: weather,
      );
    }

    // По умолчанию — персонализированные
    return await _repository.getPersonalizedRecommendations(
      userId: userId,
      weather: weather,
      userPreferences: userPreferences,
      limit: limit,
    );
  }
}
