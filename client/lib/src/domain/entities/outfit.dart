// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/outfit_occasion.dart';
import '../enums/outfit_weather.dart';
import '../enums/outfit_season.dart';

part 'outfit.freezed.dart';
part 'outfit.g.dart';

@freezed
abstract class Outfit with _$Outfit {
  const factory Outfit({
    int? id,
    String? name,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'clothing_item_ids') @Default([]) List<int> clothingItemIds,
    @Default([]) List<OutfitOccasion> occasions,
    @JsonKey(name: 'weather_conditions')
    @Default([])
    List<OutfitWeather> weatherConditions,
    @Default([]) List<OutfitSeason> seasons,
    @Default([]) List<String> tags,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default(0) int timesWorn,
    @Default(0.0) double comfortRating,
    DateTime? addedDate,
  }) = _Outfit;

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);
}
