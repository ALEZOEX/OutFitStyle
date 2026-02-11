import 'package:dartz/dartz.dart';
import '../entities/recommendation.dart';
import '../entities/weather_data.dart';
import '../repositories/recommendation_repository.dart';

class GetRecommendationsByWeather {
  final RecommendationRepository _repository;

  GetRecommendationsByWeather(this._repository);

  Future<Either<String, List<Recommendation>>> call({
    required String userId,
    required WeatherData weather,
  }) async {
    return await _repository.getRecommendationsByWeather(
      userId: userId,
      weather: weather,
    );
  }
}
