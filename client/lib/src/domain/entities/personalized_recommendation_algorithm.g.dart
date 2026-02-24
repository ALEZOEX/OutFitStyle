// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personalized_recommendation_algorithm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonalizedRecommendationAlgorithm
_$PersonalizedRecommendationAlgorithmFromJson(
  Map<String, dynamic> json,
) => _PersonalizedRecommendationAlgorithm(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  type:
      $enumDecodeNullable(_$RecommendationAlgorithmTypeEnumMap, json['type']) ??
      RecommendationAlgorithmType.collaborativeFiltering,
  accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
  precision: (json['precision'] as num?)?.toDouble() ?? 0.0,
  recall: (json['recall'] as num?)?.toDouble() ?? 0.0,
  f1Score: (json['f1Score'] as num?)?.toDouble() ?? 0.0,
  featuresUsed:
      (json['featuresUsed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weights:
      (json['weights'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  personalizationLevel:
      $enumDecodeNullable(
        _$PersonalizationLevelEnumMap,
        json['personalizationLevel'],
      ) ??
      PersonalizationLevel.high,
  trainingSamples: (json['trainingSamples'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? false,
  isDefault: json['isDefault'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  dummyField: json['dummyField'] as String? ?? '',
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PersonalizedRecommendationAlgorithmToJson(
  _PersonalizedRecommendationAlgorithm instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'type': _$RecommendationAlgorithmTypeEnumMap[instance.type]!,
  'accuracy': instance.accuracy,
  'precision': instance.precision,
  'recall': instance.recall,
  'f1Score': instance.f1Score,
  'featuresUsed': instance.featuresUsed,
  'weights': instance.weights,
  'personalizationLevel':
      _$PersonalizationLevelEnumMap[instance.personalizationLevel]!,
  'trainingSamples': instance.trainingSamples,
  'isActive': instance.isActive,
  'isDefault': instance.isDefault,
  'tags': instance.tags,
  'dummyField': instance.dummyField,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$RecommendationAlgorithmTypeEnumMap = {
  RecommendationAlgorithmType.collaborativeFiltering: 'collaborativeFiltering',
  RecommendationAlgorithmType.contentBased: 'contentBased',
  RecommendationAlgorithmType.matrixFactorization: 'matrixFactorization',
  RecommendationAlgorithmType.deepLearning: 'deepLearning',
  RecommendationAlgorithmType.hybrid: 'hybrid',
  RecommendationAlgorithmType.knowledgeBased: 'knowledgeBased',
  RecommendationAlgorithmType.demographicFiltering: 'demographicFiltering',
  RecommendationAlgorithmType.popularityBased: 'popularityBased',
};

const _$PersonalizationLevelEnumMap = {
  PersonalizationLevel.low: 'low',
  PersonalizationLevel.medium: 'medium',
  PersonalizationLevel.high: 'high',
  PersonalizationLevel.extreme: 'extreme',
};
