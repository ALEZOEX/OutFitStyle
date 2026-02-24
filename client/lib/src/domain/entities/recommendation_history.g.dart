// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendationHistory _$RecommendationHistoryFromJson(
  Map<String, dynamic> json,
) => _RecommendationHistory(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  recommendation: const RecommendationConverter().fromJson(
    json['recommendation'],
  ),
  isUsed: json['isUsed'] as bool? ?? false,
  isLiked: json['isLiked'] as bool? ?? false,
  isSaved: json['isSaved'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RecommendationHistoryToJson(
  _RecommendationHistory instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'recommendation': const RecommendationConverter().toJson(
    instance.recommendation,
  ),
  'isUsed': instance.isUsed,
  'isLiked': instance.isLiked,
  'isSaved': instance.isSaved,
  'rating': instance.rating,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
