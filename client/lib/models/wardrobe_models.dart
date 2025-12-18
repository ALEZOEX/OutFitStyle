class ClothingItemLite {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String? iconEmoji;
  final String style;
  final String source;

  ClothingItemLite({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.style,
    required this.source,
    this.iconEmoji,
  });

  factory ClothingItemLite.fromJson(Map<String, dynamic> json) {
    return ClothingItemLite(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      subcategory: (json['subcategory'] ?? '') as String,
      style: (json['style'] ?? '') as String,
      source: (json['source'] ?? '') as String,
      iconEmoji: json['icon_emoji'] as String?,
    );
  }
}

class WardrobeItem {
  final String id;
  final bool isFavorite;
  final bool isArchived;
  final int wearCount;
  final ClothingItemLite item;

  WardrobeItem({
    required this.id,
    required this.isFavorite,
    required this.isArchived,
    required this.wearCount,
    required this.item,
  });

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id'] as String,
      isFavorite: (json['is_favorite'] ?? false) as bool,
      isArchived: (json['is_archived'] ?? false) as bool,
      wearCount: (json['wear_count'] ?? 0) as int,
      item: ClothingItemLite.fromJson(json['item'] as Map<String, dynamic>),
    );
  }
}