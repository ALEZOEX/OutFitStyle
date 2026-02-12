import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_recommendation.freezed.dart';

@freezed
class OutfitRecommendation with _$OutfitRecommendation {
  const factory OutfitRecommendation({
    required String id,
    required String userId,
    required String weatherCondition,
    required double temperature,
    required List<String> clothingItems,
    required DateTime createdAt,
    required double confidenceScore,
    String? feedback,
    bool? isLiked,
    bool? isSaved,
    Map<String, dynamic>? metadata,
  }) = _OutfitRecommendation;
}