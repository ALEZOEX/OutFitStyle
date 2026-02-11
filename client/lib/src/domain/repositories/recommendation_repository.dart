import 'package:dartz/dartz.dart';
import '../entities/recommendation.dart';
import '../entities/weather_data.dart';
import '../enums/recommendation_type.dart';
import '../enums/recommendation_source.dart';

abstract class RecommendationRepository {
  Future<Either<String, List<Recommendation>>> getRecommendations({
    int? userId,
    int? outfitId,
    String? weatherCondition,
    RecommendationType? type,
    RecommendationSource? source,
  });

  Future<Either<String, List<Recommendation>>> getPersonalizedRecommendations({
    required String userId,
    required WeatherData weather,
    required Map<String, dynamic> userPreferences,
    int limit = 10,
  });

  Future<Either<String, List<Recommendation>>> getRecommendationsByOccasion({
    required String userId,
    required String occasion,
    required WeatherData weather,
  });

  Future<Either<String, List<Recommendation>>> getRecommendationsByWeather({
    required String userId,
    required WeatherData weather,
  });

  Future<Either<String, Recommendation>> getRecommendationById(int id);

  Future<Either<String, Recommendation>> saveRecommendation(
      Recommendation recommendation);

  Future<Either<String, void>> likeRecommendation(
      int recommendationId, bool isLiked);

  Future<Either<String, void>> saveRecommendationFeedback({
    required int recommendationId,
    required String feedback,
    Map<String, dynamic>? metadata,
  });

  Future<Either<String, List<Recommendation>>> getRecommendationHistory(
      int userId);

  Future<Either<String, List<Recommendation>>> getSavedRecommendations(
      int userId);

  Future<Either<String, void>> updateRecommendation(
      Recommendation recommendation);

  Future<Either<String, void>> deleteRecommendation(int id);
}
