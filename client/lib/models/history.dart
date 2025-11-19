class HistoryItem {
  final int recommendationId;
  final DateTime createdAt;
  final String location;
  final double temperature;
  final String weather;
  final double outfitScore;
  final List<Map<String, dynamic>> items;

  HistoryItem({
    required this.recommendationId,
    required this.createdAt,
    required this.location,
    required this.temperature,
    required this.weather,
    required this.outfitScore,
    required this.items,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      recommendationId: json['recommendation_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      weather: json['weather'] ?? '',
      outfitScore: (json['outfit_score'] ?? 0.0).toDouble(),
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
    );
  }
}