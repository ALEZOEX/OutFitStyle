// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/clothing_category.dart';
import '../enums/clothing_season.dart';
import '../enums/clothing_weather.dart';

part 'clothing_item.freezed.dart';
part 'clothing_item.g.dart';

@freezed
class ClothingItem with _$ClothingItem {
  const factory ClothingItem({
    int? id,
    String? name,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default([]) List<String> tags,
    @Default(ClothingCategory.tops) ClothingCategory category,
    String? color,
    String? brand,
    String? material,
    @Default([]) List<ClothingSeason> seasons,
    @Default([]) List<ClothingWeather> weatherConditions,
    @Default(false) bool isFavorite,
    @Default(false) bool isArchived,
    @Default([]) List<String> occasions,
    @Default(0) int usageCount,
    @Default(0) int timesWorn,
    @Default(0.0) double comfortRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? addedDate,
    DateTime? lastWornDate,
    double? price,
    String? size,
  }) = _ClothingItem;

  factory ClothingItem.fromJson(Map<String, dynamic> json) =>
      _$ClothingItemFromJson(json);
}
