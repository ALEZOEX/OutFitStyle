import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_recommendation.freezed.dart';

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

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      recommendedItems: (json['recommended_items'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      weatherCondition: json['weather_condition'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}

extension OutfitRecommendationJson on OutfitRecommendation {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'recommended_items': recommendedItems,
      'temperature': temperature,
      'weather_condition': weatherCondition,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
