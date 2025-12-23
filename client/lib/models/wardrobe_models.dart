class WardrobeItem {
  final String name;
  final String category;
  final String? subcategory;
  final String style;
  final String? iconEmoji;

  const WardrobeItem({
    required this.name,
    required this.category,
    this.subcategory,
    this.style = '',
    this.iconEmoji,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'style': style,
        'icon_emoji': iconEmoji,
      };

  factory WardrobeItem.fromJson(Map<String, dynamic> json) => WardrobeItem(
        name: json['name'] as String,
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        style: json['style'] as String? ?? '',
        iconEmoji: json['icon_emoji'] as String?,
      );
}

class WardrobeItemResponse {
  final String id;
  final WardrobeItem item;
  final bool isFavorite;
  final bool isArchived;
  final int wearCount;

  const WardrobeItemResponse({
    required this.id,
    required this.item,
    this.isFavorite = false,
    this.isArchived = false,
    this.wearCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item.toJson(),
        'is_favorite': isFavorite,
        'is_archived': isArchived,
        'wear_count': wearCount,
      };

  factory WardrobeItemResponse.fromJson(Map<String, dynamic> json) => WardrobeItemResponse(
        id: json['id'] as String,
        item: WardrobeItem.fromJson(json['item'] as Map<String, dynamic>),
        isFavorite: json['is_favorite'] as bool? ?? false,
        isArchived: json['is_archived'] as bool? ?? false,
        wearCount: json['wear_count'] as int? ?? 0,
      );
}