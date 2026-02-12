abstract class IRecommendationsRepository {
  Future<List<dynamic>> getRecommendations(double temperature, String weatherCondition);
  Future<void> saveRecommendation(dynamic recommendation);
  Future<List<dynamic>> getHistory();
}