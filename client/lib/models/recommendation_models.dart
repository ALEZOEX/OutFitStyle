class RecommendationRecord {
  final String id;
  final DateTime createdAt;
  final bool isFavorite;
  final List<OutfitItem> outfitData;
  final Map<String, dynamic> weatherData;

  const RecommendationRecord({
    required this.id,
    required this.createdAt,
    this.isFavorite = false,
    required this.outfitData,
    required this.weatherData,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'is_favorite': isFavorite,
        'outfit_data': outfitData.map((e) => e.toJson()).toList(),
        'weather_data': weatherData,
      };

  factory RecommendationRecord.fromJson(Map<String, dynamic> json) =>
      RecommendationRecord(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        isFavorite: json['is_favorite'] as bool? ?? false,
        outfitData: (json['outfit_data'] as List)
            .map((e) => OutfitItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        weatherData: json['weather_data'] as Map<String, dynamic>,
      );
}

class OutfitItem {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String style;
  final String? iconEmoji;
  final String? imageUrl;

  const OutfitItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.style = '',
    this.iconEmoji,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'style': style,
        'icon_emoji': iconEmoji,
        'image_url': imageUrl,
      };

  factory OutfitItem.fromJson(Map<String, dynamic> json) => OutfitItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        style: json['style'] as String? ?? '',
        iconEmoji: json['icon_emoji'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}
