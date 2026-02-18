import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe_item.freezed.dart';
part 'wardrobe_item.g.dart';

@freezed
abstract class WardrobeItem with _$WardrobeItem {
  const factory WardrobeItem({
    String? id,
    String? name,
    String? category,
    String? subcategory,
    String? brand,
    String? color,
    String? size,
    String? imageUrl,
    String? iconEmoji,
    String? blurHash,
    double? minTemp,
    double? maxTemp,
    int? warmthLevel,
    bool? rainOk,
    bool? snowOk,
    bool? windOk,
    int? usage,
    List<String>? materials,
    String? gender,
    String? fit,
    String? pattern,
    String? localImagePath,
    String? style,
    bool? isFavorite,
    bool? isArchived,
    String? season,
    String? serverId,
    bool? dirty,
    DateTime? lastSyncedAt,
  }) = _WardrobeItem;

  factory WardrobeItem.fromJson(Map<String, dynamic> json) =>
      _$WardrobeItemFromJson(json);
}