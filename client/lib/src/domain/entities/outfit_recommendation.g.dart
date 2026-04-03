// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit_recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutfitRecommendation _$OutfitRecommendationFromJson(
  Map<String, dynamic> json,
) => _OutfitRecommendation(
  id: json['id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  recommendedItems: (json['recommended_items'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  temperature: (json['temperature'] as num?)?.toDouble(),
  weatherCondition: json['weather_condition'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$OutfitRecommendationToJson(
  _OutfitRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'recommended_items': instance.recommendedItems,
  'temperature': instance.temperature,
  'weather_condition': instance.weatherCondition,
  'created_at': instance.createdAt?.toIso8601String(),
};
