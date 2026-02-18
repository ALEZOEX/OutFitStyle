import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_item.freezed.dart';
part 'wardrobe_item.g.dart';

@freezed
abstract class WardrobeItem with _$WardrobeItem {
  const factory WardrobeItem({
    required String id,
    required String name,
    required String category,
    String? subcategory,
    required String imageUrl,
    @Default(false) bool isFavorite,
    @Default(false) bool isActive,
    String? description,
    String? brand,
    String? color,
    String? size,
    int? minTemp,
    int? maxTemp,
    String? style,
    @Default(false) bool rainOk,
    List<String>? seasons,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WardrobeItem;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) =>
      _$WardrobeItemFromJson(json);
}
