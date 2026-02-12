import 'package:freezed_annotation/freezed_annotation.dart';

part 'wardrobe.freezed.dart';

@freezed
class WardrobeItem with _$WardrobeItem {
  const factory WardrobeItem({
    required String id,
    required String userId,
    required String name,
    required String category,
    required String subcategory,
    required String brand,
    required String color,
    required String size,
    required String material,
    required String season,
    required String weatherCondition,
    required double temperatureMin,
    required double temperatureMax,
    required String imageUrl,
    required bool isFavorite,
    required bool isArchived,
    required DateTime addedAt,
    required DateTime updatedAt,
    Map<String, dynamic>? metadata,
  }) = _WardrobeItem;
}