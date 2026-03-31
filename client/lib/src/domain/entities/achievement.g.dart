// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Achievement _$AchievementFromJson(Map<String, dynamic> json) => _Achievement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  category: $enumDecode(_$AchievementCategoryEnumMap, json['category']),
  points: (json['points'] as num).toInt(),
  currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
  targetValue: (json['targetValue'] as num?)?.toInt() ?? 1,
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  userId: json['userId'] as String?,
  reward: json['reward'] as String? ?? '',
  isVisible: json['isVisible'] as bool? ?? true,
  type: json['type'] as String?,
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'category': _$AchievementCategoryEnumMap[instance.category]!,
      'points': instance.points,
      'currentProgress': instance.currentProgress,
      'targetValue': instance.targetValue,
      'isUnlocked': instance.isUnlocked,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'userId': instance.userId,
      'reward': instance.reward,
      'isVisible': instance.isVisible,
      'type': instance.type,
    };

const _$AchievementCategoryEnumMap = {
  AchievementCategory.wardrobe: 'wardrobe',
  AchievementCategory.recommendations: 'recommendations',
  AchievementCategory.weather: 'weather',
  AchievementCategory.time: 'time',
  AchievementCategory.planning: 'planning',
  AchievementCategory.ratings: 'ratings',
  AchievementCategory.family: 'family',
  AchievementCategory.special: 'special',
  AchievementCategory.starter: 'starter',
};
