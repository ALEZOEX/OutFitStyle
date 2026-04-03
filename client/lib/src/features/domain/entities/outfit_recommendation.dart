import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_recommendation.freezed.dart';

@freezed
abstract class OutfitRecommendation with _$OutfitRecommendation {
  const factory OutfitRecommendation({
    required String id,
    required String title,
    required String description,
    @Default([]) List<String> outfitImageUrls,
    @Default(null) String? imageUrl,
    @Default([]) List<String> recommendedItems,
    @Default(null) String? weatherCondition,
    @Default(null) int? temperature,
    @Default(null) String? occasion,
    @Default(0.0) double? confidenceScore,
    @Default(null) DateTime? createdAt,
  }) = _OutfitRecommendation;

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      outfitImageUrls: (json['outfit_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      recommendedItems: (json['recommended_items'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weatherCondition: json['weather_condition'] as String?,
      temperature: json['temperature'] as int?,
      occasion: json['occasion'] as String?,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'outfit_image_urls': outfitImageUrls,
      'image_url': imageUrl,
      'recommended_items': recommendedItems,
      'weather_condition': weatherCondition,
      'temperature': temperature,
      'occasion': occasion,
      'confidence_score': confidenceScore,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
