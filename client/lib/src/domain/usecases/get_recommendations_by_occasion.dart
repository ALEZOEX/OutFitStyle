import 'package:dartz/dartz.dart';
import '../entities/recommendation.dart';
import '../entities/weather_data.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendationsByOccasion {
  final RecommendationRepository _repository;

  GetRecommendationsByOccasion(this._repository);

  Future<Either<String, List<Recommendation>>> call({
    required String userId,
    required String occasion,
    required WeatherData weather,
  }) async {
    return await _repository.getRecommendationsByOccasion(
      userId: userId,
      occasion: occasion,
      weather: weather,
    );
  }
}
