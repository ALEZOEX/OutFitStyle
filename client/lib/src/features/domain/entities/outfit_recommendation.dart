import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_recommendation.freezed.dart';
part 'outfit_recommendation.g.dart';

@freezed
abstract class OutfitRecommendation with _$OutfitRecommendation {
  const factory OutfitRecommendation({
    required String id,
    required String title,
    required String description,
    @Default([]) List<String> outfitImageUrls,
    @Default(null) String? imageUrl,
    @Default(null) List<String>? recommendedItems,
    @Default(null) String? weatherCondition,
    @Default(null) int? temperature,
    @Default(null) String? occasion,
    @Default(false) bool isLiked,
    @Default(false) bool isSaved,
    @Default(0.0) double? confidenceScore,
    @Default(null) DateTime? createdAt,
  }) = _OutfitRecommendation;

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) =>
      _$OutfitRecommendationFromJson(json);
}
