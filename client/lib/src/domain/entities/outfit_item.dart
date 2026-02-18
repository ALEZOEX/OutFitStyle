import 'package:freezed_annotation/freezed_annotation.dart';
import 'clothing_item.dart';

part 'outfit_item.freezed.dart';

@freezed
abstract class OutfitItem with _$OutfitItem {
  const factory OutfitItem({
    int? id,
    int? outfitId,
    int? clothingItemId,
    ClothingItem? clothingItem,
    @Default(0) int sortOrder,
    @Default(false) bool isPrimary,
    @Default({}) Map<String, dynamic> metadata,
  }) = _OutfitItem;
}
