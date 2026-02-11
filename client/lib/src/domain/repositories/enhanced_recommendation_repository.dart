import '../entities/recommendation.dart';
import '../entities/weather_data.dart';
import '../entities/user_preference.dart';
import '../entities/recommendation_feedback.dart';
import '../entities/recommendation_history.dart';
import '../entities/personalized_recommendation_algorithm.dart';

abstract class EnhancedRecommendationRepository {
  /// Get personalized recommendations for the user based on preferences, weather, and ML model
  Future<List<Recommendation>> getPersonalizedRecommendations({
    required String userId,
    required WeatherData weather,
    required Map<String, dynamic> userPreferences,
    int limit = 10,
  });

  /// Get recommendations for a specific occasion
  Future<List<Recommendation>> getRecommendationsByOccasion({
    required String userId,
    required String occasion,
    required WeatherData weather,
  });

  /// Get recommendations for specific weather conditions
  Future<List<Recommendation>> getRecommendationsByWeather({
    required String userId,
    required WeatherData weather,
  });

  /// Save a recommendation to user's favorites
  Future<void> saveRecommendation({
    required String userId,
    required String recommendationId,
  });

  /// Like/unlike a recommendation
  Future<void> likeRecommendation({
    required String userId,
    required String recommendationId,
    required bool liked,
  });

  /// Update recommendation feedback
  Future<void> updateRecommendationFeedback({
    required String userId,
    required String recommendationId,
    required List<String> feedback,
  });

  /// Get user's saved recommendations
  Future<List<Recommendation>> getSavedRecommendations({
    required String userId,
  });

  /// Get user's liked recommendations
  Future<List<Recommendation>> getLikedRecommendations({
    required String userId,
  });

  /// Submit detailed feedback for a recommendation
  Future<void> submitFeedback({
    required String userId,
    required String recommendationId,
    required RecommendationFeedback feedback,
  });

  /// Get recommendation feedback for a specific recommendation
  Future<RecommendationFeedback?> getFeedback({
    required String userId,
    required String recommendationId,
  });

  /// Get all feedback for a user
  Future<List<RecommendationFeedback>> getUserFeedback({
    required String userId,
  });

  /// Get recommendation history for a user
  Future<List<RecommendationHistory>> getRecommendationHistory({
    required String userId,
    int limit = 50,
  });

  /// Add a recommendation to history
  Future<void> addToHistory({
    required String userId,
    required String recommendationId,
    required String action,
    String reason = '',
  });

  /// Get user preferences
  Future<UserPreference> getUserPreferences({
    required String userId,
  });

  /// Update user preferences
  Future<void> updateUserPreferences({
    required String userId,
    required UserPreference preferences,
  });

  /// Get recommendation algorithms
  Future<List<PersonalizedRecommendationAlgorithm>>
      getRecommendationAlgorithms();

  /// Get active recommendation algorithm
  Future<PersonalizedRecommendationAlgorithm> getActiveAlgorithm();

  /// Get recommendations by algorithm
  Future<List<Recommendation>> getRecommendationsByAlgorithm({
    required String userId,
    required String algorithmId,
    required WeatherData weather,
    required Map<String, dynamic> userPreferences,
  });

  /// Get similar recommendations to a specific recommendation
  Future<List<Recommendation>> getSimilarRecommendations({
    required String userId,
    required String recommendationId,
    required WeatherData weather,
    int limit = 5,
  });

  /// Archive a recommendation
  Future<void> archiveRecommendation({
    required String userId,
    required String recommendationId,
  });

  /// Mark a recommendation as used
  Future<void> markAsUsed({
    required String userId,
    required String recommendationId,
  });

  /// Get most used recommendations
  Future<List<Recommendation>> getMostUsedRecommendations({
    required String userId,
    int limit = 10,
  });

  /// Get recommendations by rating
  Future<List<Recommendation>> getRecommendationsByRating({
    required String userId,
    required int minRating,
    int limit = 10,
  });
}
