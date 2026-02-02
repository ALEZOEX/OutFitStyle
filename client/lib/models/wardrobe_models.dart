import 'clothing_item.dart';

class WardrobeItem {
  final String id;
  final String userId;
  final String clothingItemId;

  final String? customName;
  final String? notes;
  final List<String> tags;

  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? purchaseCurrency;

  final int wearCount;
  final DateTime? lastWornAt;

  final bool isFavorite;
  final bool isArchived;
  final String condition;

  final DateTime createdAt;
  final DateTime updatedAt;

  final ClothingItem item;

  // Дополнительные поля для интеграции с рекомендациями
  final String? season;
  final bool rainOk;
  final bool snowOk;
  final bool windOk;
  final int? warmthLevel;
  final int? minTemp;
  final int? maxTemp;

  const WardrobeItem({
    required this.id,
    required this.userId,
    required this.clothingItemId,
    this.customName,
    this.notes,
    this.tags = const [],
    this.purchaseDate,
    this.purchasePrice,
    this.purchaseCurrency,
    required this.wearCount,
    this.lastWornAt,
    required this.isFavorite,
    required this.isArchived,
    required this.condition,
    required this.createdAt,
    required this.updatedAt,
    required this.item,
    this.season,
    this.rainOk = false,
    this.snowOk = false,
    this.windOk = false,
    this.warmthLevel,
    this.minTemp,
    this.maxTemp,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) => WardrobeItem(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        clothingItemId: json['clothing_item_id'] as String,
        customName: json['custom_name'] as String?,
        notes: json['notes'] as String?,
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        purchaseDate: json['purchase_date'] != null ? DateTime.parse(json['purchase_date'] as String) : null,
        purchasePrice: json['purchase_price'] as double?,
        purchaseCurrency: json['purchase_currency'] as String?,
        wearCount: json['wear_count'] as int? ?? 0,
        lastWornAt: json['last_worn_at'] != null ? DateTime.parse(json['last_worn_at'] as String) : null,
        isFavorite: json['is_favorite'] as bool? ?? false,
        isArchived: json['is_archived'] as bool? ?? false,
        condition: json['condition'] as String? ?? 'good',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        item: ClothingItem.fromJson(json['item'] as Map<String, dynamic>),
        season: json['season'] as String?,
        rainOk: json['rain_ok'] as bool? ?? false,
        snowOk: json['snow_ok'] as bool? ?? false,
        windOk: json['wind_ok'] as bool? ?? false,
        warmthLevel: json['warmth_level'] as int?,
        minTemp: json['min_temp'] as int?,
        maxTemp: json['max_temp'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'clothing_item_id': clothingItemId,
        'custom_name': customName,
        'notes': notes,
        'tags': tags,
        'purchase_date': purchaseDate?.toIso8601String(),
        'purchase_price': purchasePrice,
        'purchase_currency': purchaseCurrency,
        'wear_count': wearCount,
        'last_worn_at': lastWornAt?.toIso8601String(),
        'is_favorite': isFavorite,
        'is_archived': isArchived,
        'condition': condition,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'item': item.toJson(),
        'season': season,
        'rain_ok': rainOk,
        'snow_ok': snowOk,
        'wind_ok': windOk,
        'warmth_level': warmthLevel,
        'min_temp': minTemp,
        'max_temp': maxTemp,
      };
}

class WardrobeCreateRequest {
  final String? clothingItemId;
  final String? name;
  final String? category;
  final String? subcategory;
  final String? style;
  final String? baseColour;
  final String? customName;
  final String? notes;
  final List<String> tags;

  const WardrobeCreateRequest({
    this.clothingItemId,
    this.name,
    this.category,
    this.subcategory,
    this.style,
    this.baseColour,
    this.customName,
    this.notes,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'clothing_item_id': clothingItemId,
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'style': style,
        'base_colour': baseColour,
        'custom_name': customName,
        'notes': notes,
        'tags': tags,
      };
}

class WardrobeUpdateRequest {
  final String? customName;
  final String? notes;
  final List<String>? tags;
  final double? purchasePrice;
  final String? condition;

  const WardrobeUpdateRequest({
    this.customName,
    this.notes,
    this.tags,
    this.purchasePrice,
    this.condition,
  });

  Map<String, dynamic> toJson() => {
        'custom_name': customName,
        'notes': notes,
        'tags': tags,
        'purchase_price': purchasePrice,
        'condition': condition,
      };
}

class WardrobeToggleRequest {
  final bool? isFavorite;
  final bool? isArchived;

  const WardrobeToggleRequest({
    this.isFavorite,
    this.isArchived,
  });

  Map<String, dynamic> toJson() => {
        'is_favorite': isFavorite,
        'is_archived': isArchived,
      };
}