import '../utils/json_converter.dart';

class ClothingItem {
  final int id;
  final String name;
  final String category;
  final String? subcategory;
  final String iconEmoji;
  final double? mlScore;
  final bool mlPowered;
  final String? weatherSuitability;

  // Extended attributes for unified catalog
  final String? gender;
  final String? masterCategory;
  final String? season;
  final String? baseColour;
  final String? usage;
  final String source;  // wardrobe, catalog, kaggle_seed
  final bool isOwned;
  final int? ownerUserId;
  final double? minTemp;
  final double? maxTemp;
  final int? warmthLevel;
  final int? formalityLevel;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.iconEmoji,
    this.mlScore,
    this.mlPowered = false,
    this.weatherSuitability,
    this.gender,
    this.masterCategory,
    this.season,
    this.baseColour,
    this.usage,
    this.source = 'catalog',
    this.isOwned = false,
    this.ownerUserId,
    this.minTemp,
    this.maxTemp,
    this.warmthLevel,
    this.formalityLevel,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: JsonConverter.toInt(json['id']) ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      iconEmoji: json['icon_emoji'] as String? ?? '👕',
      mlScore: JsonConverter.toDouble(json['ml_score']),
      mlPowered: json['ml_powered'] as bool? ?? false,
      weatherSuitability: json['weather_suitability'] as String?,
      gender: json['gender'] as String?,
      masterCategory: json['master_category'] as String?,
      season: json['season'] as String?,
      baseColour: json['base_colour'] as String?,
      usage: json['usage'] as String?,
      source: json['source'] as String? ?? 'catalog',
      isOwned: json['is_owned'] as bool? ?? false,
      ownerUserId: JsonConverter.toInt(json['owner_user_id']),
      minTemp: JsonConverter.toDouble(json['min_temp']),
      maxTemp: JsonConverter.toDouble(json['max_temp']),
      warmthLevel: JsonConverter.toInt(json['warmth_level']),
      formalityLevel: JsonConverter.toInt(json['formality_level']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'icon_emoji': iconEmoji,
      'ml_score': mlScore,
      'ml_powered': mlPowered,
      'weather_suitability': weatherSuitability,
      'gender': gender,
      'master_category': masterCategory,
      'season': season,
      'base_colour': baseColour,
      'usage': usage,
      'source': source,
      'is_owned': isOwned,
      'owner_user_id': ownerUserId,
      'min_temp': minTemp,
      'max_temp': maxTemp,
      'warmth_level': warmthLevel,
      'formality_level': formalityLevel,
    };
  }

  // Методы для UI отображения
  String getSourceDisplayText() {
    switch (source) {
      case 'wardrobe':
        return isOwned ? 'Твой гардероб' : 'Чужой гардероб';
      case 'catalog':
        return 'Каталог';
      case 'marketplace':
        return 'Магазин';
      case 'kaggle_seed':
        return 'Образец';
      default:
        return 'Неизвестный';
    }
  }

  bool get isFromWardrobe => source == 'wardrobe' && isOwned;
  bool get isFromCatalog => source == 'catalog';
  bool get isFromKaggleSeed => source == 'kaggle_seed';

  // Возвращает цвет для отображения в UI в зависимости от источника
  String getTagColor() {
    if (isFromWardrobe) {
      return '#4CAF50'; // Зеленый для своего гардероба
    } else if (isFromCatalog) {
      return '#2196F3'; // Синий для каталога
    } else if (isFromKaggleSeed) {
      return '#FF9800'; // Оранжевый для kaggle_seed
    }
    return '#9E9E9E'; // Серый для других
  }
}

class Recommendation {
  final String location;
  final double temperature;
  final String weather;
  final String message;
  final List<ClothingItem> items;
  final int id;
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
    required this.id,
    required this.humidity,
    required this.windSpeed,
    required this.mlPowered,
    this.outfitScore,
    this.algorithm,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    return Recommendation(
      location: json['location'] as String? ?? '',
      temperature: JsonConverter.toDouble(json['temperature']) ?? 0.0,
      weather: json['weather'] as String? ?? '',
      message: json['message'] as String? ?? '',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ClothingItem.fromJson)
          .toList(),
      id: JsonConverter.toInt(json['id'] ?? json['recommendation_id']) ?? 0,
      humidity: JsonConverter.toInt(json['humidity']) ?? 0,
      windSpeed: JsonConverter.toDouble(json['wind_speed']) ?? 0.0,
      mlPowered: json['ml_powered'] as bool? ?? false,
      outfitScore: JsonConverter.toDouble(json['outfit_score']),
      algorithm: json['algorithm'] as String?,
    );
  }
}