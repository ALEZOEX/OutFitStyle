// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/recommendation_type.dart';
import '../enums/recommendation_source.dart';
import 'outfit.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

class OutfitConverter implements JsonConverter<Outfit?, Map<String, dynamic>?> {
  const OutfitConverter();

  @override
  Outfit? fromJson(Map<String, dynamic>? json) {
    return json != null ? Outfit.fromJson(json) : null;
  }

  @override
  Map<String, dynamic>? toJson(Outfit? object) => object?.toJson();
}

@freezed
abstract class Recommendation with _$Recommendation {
  const factory Recommendation({
    int? id,
    String? title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    RecommendationType? type,
    RecommendationSource? source,
    @JsonKey(name: 'confidence_score') double? confidenceScore,
    @JsonKey(name: 'created_at') DateTime? createdAt,

    // Поля, которые используются в виджетах
    @JsonKey(name: 'outfit') @OutfitConverter() Outfit? outfit,
    String? occasion,
    String? activity,
    String? weather,
    double? rating,
    @JsonKey(name: 'usage_count') int? usageCount,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    @JsonKey(name: 'is_saved') @Default(false) bool isSaved,
    @JsonKey(name: 'is_used') @Default(false) bool isUsed,
    @JsonKey(name: 'recommendation_reason') String? recommendationReason,
    @Default([]) List<String> tags,

    // Старые поля
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'outfit_id') int? outfitId,
    @JsonKey(name: 'weather_condition') String? weatherCondition,
    @JsonKey(name: 'recommended_items') List<String>? recommendedItems,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'is_liked') bool? isLiked,
    String? feedback,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}
