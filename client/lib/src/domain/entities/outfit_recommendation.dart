import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_recommendation.freezed.dart';
part 'outfit_recommendation.g.dart';

@freezed
abstract class OutfitRecommendation with _$OutfitRecommendation {
  const factory OutfitRecommendation({
    String? id,
    String? title,
    String? description,
    @JsonKey(name: 'recommended_items') List<String>? recommendedItems,
    double? temperature,
    @JsonKey(name: 'weather_condition') String? weatherCondition,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _OutfitRecommendation;

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$OutfitRecommendationFromJson(json);
}
