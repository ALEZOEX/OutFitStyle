class WeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String weather;
  final int humidity;
  final double windSpeed;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.feelsLike,
    required this.weather,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: json['location'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      feelsLike: (json['feels_like'] ?? 0).toDouble(),
      weather: json['weather'] ?? '',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
    );
  }
}

class ClothingItem {
  final int id;
  final String name;
  final String category;
  final String? subcategory;
  final String iconEmoji;
  final double? mlScore;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.iconEmoji,
    this.mlScore,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'],
      iconEmoji: json['icon_emoji'] ?? '👕',
      mlScore: json['ml_score']?.toDouble(),
    );
  }
}

class Recommendation {
  final String location;
  final double temperature;
  final String weather;
  final String message;
  final List<ClothingItem> items;
  final int humidity;
  final double windSpeed;
  final bool mlPowered;
  final double? outfitScore;
  final String? algorithm;

  Recommendation({
    required this.location,
    required this.temperature,
    required this.weather,
    required this.message,
    required this.items,
    required this.humidity,
    required this.windSpeed,
    required this.mlPowered,
    this.outfitScore,
    this.algorithm,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      location: json['location'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      weather: json['weather'] ?? '',
      message: json['message'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => ClothingItem.fromJson(item))
              .toList() ??
          [],
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      mlPowered: json['ml_powered'] ?? false,
      outfitScore: json['outfit_score']?.toDouble(),
      algorithm: json['algorithm'],
    );
  }
}