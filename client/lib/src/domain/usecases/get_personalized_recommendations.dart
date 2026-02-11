import 'package:dartz/dartz.dart';
import '../entities/recommendation.dart';
import '../entities/weather_data.dart';
import '../repositories/recommendation_repository.dart';

class GetPersonalizedRecommendations {
  final RecommendationRepository _repository;

  GetPersonalizedRecommendations(this._repository);

  Future<Either<String, List<Recommendation>>> call({
    required String userId,
    required WeatherData weather,
    required Map<String, dynamic> userPreferences,
    int limit = 10,
  }) async {
    return await _repository.getPersonalizedRecommendations(
      userId: userId,
      weather: weather,
      userPreferences: userPreferences,
      limit: limit,
    );
  }
}
