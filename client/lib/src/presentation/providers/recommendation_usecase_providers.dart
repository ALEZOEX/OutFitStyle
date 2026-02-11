import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_personalized_recommendations.dart';
import '../../domain/usecases/get_recommendations_by_occasion.dart';
import '../../domain/usecases/get_recommendations_by_weather.dart';
import 'repository_providers.dart';

final getPersonalizedRecommendationsProvider = Provider(
  (ref) => GetPersonalizedRecommendations(
    ref.watch(recommendationRepositoryProvider),
  ),
);

final getRecommendationsByOccasionProvider = Provider(
  (ref) => GetRecommendationsByOccasion(
    ref.watch(recommendationRepositoryProvider),
  ),
);

final getRecommendationsByWeatherProvider = Provider(
  (ref) => GetRecommendationsByWeather(
    ref.watch(recommendationRepositoryProvider),
  ),
);
