import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_recommendation.freezed.dart';
part 'outfit_recommendation.g.dart';

@freezed
abstract class OutfitRecommendation with _$OutfitRecommendation {
  const factory OutfitRecommendation({
    String? id,
    String? title,
    String? description,
    List<String>? recommendedItems,
    double? temperature,
    String? weatherCondition,
    DateTime? createdAt,
  }) = _OutfitRecommendation;

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$OutfitRecommendationFromJson(json);
}
