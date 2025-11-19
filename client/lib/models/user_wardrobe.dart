/// Enum for clothing categories
enum ClothingCategory {
  top('Верх'),
  bottom('Низ'), 
  footwear('Обувь'),
  outerwear('Верхняя одежда'),
  accessories('Аксессуары'),
  dress('Платья'),
  suit('Костюмы');

  const ClothingCategory(this.displayName);
  final String displayName;
}

/// Enum for clothing seasons
enum ClothingSeason {
  spring('Весна'),
  summer('Лето'), 
  autumn('Осень'),
  winter('Зима'),
  allYear('Круглый год');

  const ClothingSeason(this.displayName);
  final String displayName;
}

/// Enum for clothing status
enum ClothingStatus {
  active('Активный'),
  wishlist('Список покупок'),
  archive('Архив'),
  favorite('Избранное');

  const ClothingStatus(this.displayName);
  final String displayName;
}

/// Main wardrobe item model with comprehensive metadata
class WardrobeItem {
  final int id;
  final String customName;
  final String customIcon;
  final ClothingCategory category;
  final ClothingSeason season;
  final ClothingStatus status;
  final String? brand;
  final String? color;
  final double? price;
  final DateTime? purchaseDate;
  final List<String> tags;
  final int? size;

  WardrobeItem({
    required this.id,
    required this.customName,
    required this.customIcon,
    this.category = ClothingCategory.top,
    this.season = ClothingSeason.allYear,
    this.status = ClothingStatus.active,
    this.brand,
    this.color,
    this.price,
    this.purchaseDate,
    this.tags = const [],
    this.size,
  });

  /// Create WardrobeItem from JSON map
  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as int,
      customName: (json['custom_name'] as String?) ?? 'Unknown',
      customIcon: (json['custom_icon'] as String?) ?? '👕',
      category: _parseCategory(json['category']),
      season: _parseSeason(json['season']),
      status: _parseStatus(json['status']),
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      purchaseDate: json['purchase_date'] != null 
        ? DateTime.tryParse(json['purchase_date']) 
        : null,
      tags: (json['tags'] as List?)?.map((tag) => tag.toString()).toList() ?? [],
      size: json['size'] as int?,
    );
  }

  /// Convert WardrobeItem to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'custom_name': customName,
      'custom_icon': customIcon,
      'category': category.name,
      'season': season.name,
      'status': status.name,
      'brand': brand,
      'color': color,
      'price': price,
      'purchase_date': purchaseDate?.toIso8601String(),
      'tags': tags,
      'size': size,
    };
  }

  /// Helper method to parse category from string
  static ClothingCategory _parseCategory(dynamic value) {
    if (value == null) return ClothingCategory.top;
    try {
      return ClothingCategory.values.firstWhere(
        (category) => category.name == value.toString(),
        orElse: () => ClothingCategory.top,
      );
    } catch (e) {
      return ClothingCategory.top;
    }
  }

  /// Helper method to parse season from string
  static ClothingSeason _parseSeason(dynamic value) {
    if (value == null) return ClothingSeason.allYear;
    try {
      return ClothingSeason.values.firstWhere(
        (season) => season.name == value.toString(),
        orElse: () => ClothingSeason.allYear,
      );
    } catch (e) {
      return ClothingSeason.allYear;
    }
  }

  /// Helper method to parse status from string
  static ClothingStatus _parseStatus(dynamic value) {
    if (value == null) return ClothingStatus.active;
    try {
      return ClothingStatus.values.firstWhere(
        (status) => status.name == value.toString(),
        orElse: () => ClothingStatus.active,
      );
    } catch (e) {
      return ClothingStatus.active;
    }
  }
}