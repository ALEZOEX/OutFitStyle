import 'clothing_item.dart';

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
