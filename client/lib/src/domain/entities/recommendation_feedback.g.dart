// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendationFeedbackImpl _$$RecommendationFeedbackImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationFeedbackImpl(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      recommendationId: json['recommendationId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const <String>[],
      comment: json['comment'] as String? ?? '',
      likedItems: (json['likedItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      dislikedItems: (json['dislikedItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      wouldReuse: json['wouldReuse'] as bool? ?? false,
      wouldRecommend: json['wouldRecommend'] as bool? ?? false,
      improvementSuggestions: (json['improvementSuggestions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      category:
          $enumDecodeNullable(_$FeedbackCategoryEnumMap, json['category']) ??
              FeedbackCategory.general,
      source: $enumDecodeNullable(_$FeedbackSourceEnumMap, json['source']) ??
          FeedbackSource.user,
      dummyField: json['dummyField'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$RecommendationFeedbackImplToJson(
        _$RecommendationFeedbackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'recommendationId': instance.recommendationId,
      'rating': instance.rating,
      'tags': instance.tags,
      'comment': instance.comment,
      'likedItems': instance.likedItems,
      'dislikedItems': instance.dislikedItems,
      'wouldReuse': instance.wouldReuse,
      'wouldRecommend': instance.wouldRecommend,
      'improvementSuggestions': instance.improvementSuggestions,
      'category': _$FeedbackCategoryEnumMap[instance.category]!,
      'source': _$FeedbackSourceEnumMap[instance.source]!,
      'dummyField': instance.dummyField,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$FeedbackCategoryEnumMap = {
  FeedbackCategory.accuracy: 'accuracy',
  FeedbackCategory.style: 'style',
  FeedbackCategory.comfort: 'comfort',
  FeedbackCategory.weatherMatch: 'weatherMatch',
  FeedbackCategory.occasionMatch: 'occasionMatch',
  FeedbackCategory.price: 'price',
  FeedbackCategory.availability: 'availability',
  FeedbackCategory.general: 'general',
};

const _$FeedbackSourceEnumMap = {
  FeedbackSource.user: 'user',
  FeedbackSource.system: 'system',
  FeedbackSource.ai: 'ai',
};
