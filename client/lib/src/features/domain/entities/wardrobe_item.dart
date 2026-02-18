import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_item.freezed.dart';
part 'wardrobe_item.g.dart';

@freezed
class WardrobeItem with _$WardrobeItem {
  const factory WardrobeItem({
    required String id,
    required String name,
    required String category,
    @Default(null) String? subcategory,
    required String imageUrl,
    @Default(false) bool isFavorite,
    @Default(false) bool isActive,
    @Default(null) String? description,
    @Default(null) String? brand,
    @Default(null) String? color,
    @Default(null) String? size,
    @Default(null) int? minTemp,
    @Default(null) int? maxTemp,
    @Default(null) List<String>? seasons,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? updatedAt,
  }) = _WardrobeItem;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) =>
      _$WardrobeItemFromJson(json);
}
