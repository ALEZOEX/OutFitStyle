// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    _Recommendation(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      type: $enumDecodeNullable(_$RecommendationTypeEnumMap, json['type']),
      source: $enumDecodeNullable(
        _$RecommendationSourceEnumMap,
        json['source'],
      ),
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      outfit: const OutfitConverter().fromJson(
        json['outfit'] as Map<String, dynamic>?,
      ),
      occasion: json['occasion'] as String?,
      activity: json['activity'] as String?,
      weather: json['weather'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      usageCount: (json['usage_count'] as num?)?.toInt(),
      isFavorite: json['is_favorite'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      isUsed: json['is_used'] as bool? ?? false,
      recommendationReason: json['recommendation_reason'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      userId: (json['user_id'] as num?)?.toInt(),
      outfitId: (json['outfit_id'] as num?)?.toInt(),
      weatherCondition: json['weather_condition'] as String?,
      recommendedItems:
          (json['recommended_items'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isLiked: json['is_liked'] as bool?,
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$RecommendationToJson(_Recommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image_url': instance.imageUrl,
      'type': _$RecommendationTypeEnumMap[instance.type],
      'source': _$RecommendationSourceEnumMap[instance.source],
      'confidence_score': instance.confidenceScore,
      'created_at': instance.createdAt?.toIso8601String(),
      'outfit': const OutfitConverter().toJson(instance.outfit),
      'occasion': instance.occasion,
      'activity': instance.activity,
      'weather': instance.weather,
      'rating': instance.rating,
      'usage_count': instance.usageCount,
      'is_favorite': instance.isFavorite,
      'is_saved': instance.isSaved,
      'is_used': instance.isUsed,
      'recommendation_reason': instance.recommendationReason,
      'tags': instance.tags,
      'user_id': instance.userId,
      'outfit_id': instance.outfitId,
      'weather_condition': instance.weatherCondition,
      'recommended_items': instance.recommendedItems,
      'metadata': instance.metadata,
      'is_liked': instance.isLiked,
      'feedback': instance.feedback,
    };

const _$RecommendationTypeEnumMap = {
  RecommendationType.outfit: 'outfit',
  RecommendationType.clothing: 'clothing',
  RecommendationType.style: 'style',
  RecommendationType.weather: 'weather',
  RecommendationType.occasion: 'occasion',
  RecommendationType.trending: 'trending',
  RecommendationType.personalized: 'personalized',
};

const _$RecommendationSourceEnumMap = {
  RecommendationSource.weather: 'weather',
  RecommendationSource.occasion: 'occasion',
  RecommendationSource.activity: 'activity',
  RecommendationSource.trending: 'trending',
  RecommendationSource.personalized: 'personalized',
  RecommendationSource.collaborative: 'collaborative',
  RecommendationSource.contentBased: 'content_based',
  RecommendationSource.manual: 'manual',
  RecommendationSource.system: 'system',
};
