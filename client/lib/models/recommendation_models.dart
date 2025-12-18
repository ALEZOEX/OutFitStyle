class RecommendationRecord {
  final String id;
  final DateTime createdAt;
  final bool isFavorite;

  // outfit_data — большой JSON, оставим сырьём (но парсим нужное)
  final Map<String, dynamic> outfitData;
  final Map<String, dynamic> weatherData;

  RecommendationRecord({
    required this.id,
    required this.createdAt,
    required this.isFavorite,
    required this.outfitData,
    required this.weatherData,
  });

  factory RecommendationRecord.fromJson(Map<String, dynamic> json) {
    // backend хранит weather_data/outfit_data как JSONB; в ответе они приходят как Map
    final weather = (json['weather_data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final outfit = (json['outfit_data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    return RecommendationRecord(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      isFavorite: (json['is_favorite'] ?? false) as bool,
      outfitData: outfit,
      weatherData: weather,
    );
  }

  List<Map<String, dynamic>> outfitLines() {
    final arr = outfitData['outfit'];
    if (arr is List) {
      return arr.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }
}