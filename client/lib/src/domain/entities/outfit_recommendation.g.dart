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
  imageUrl: json['imageUrl'] as String?,
  recommendedItems:
      (json['recommendedItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  temperature: (json['temperature'] as num?)?.toDouble(),
  weatherCondition: json['weatherCondition'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$OutfitRecommendationToJson(
  _OutfitRecommendation instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'recommendedItems': instance.recommendedItems,
  'temperature': instance.temperature,
  'weatherCondition': instance.weatherCondition,
  'createdAt': instance.createdAt?.toIso8601String(),
};
