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
  category: json['category'] as String,
  points: (json['points'] as num).toInt(),
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  target: (json['target'] as num?)?.toInt() ?? 1,
  reward: json['reward'] as String,
  isVisible: json['isVisible'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  userId: json['userId'] as String?,
  isUnlocked: json['isUnlocked'] as bool? ?? false,
  currentProgress: (json['currentProgress'] as num?)?.toInt() ?? 0,
  targetValue: (json['targetValue'] as num?)?.toInt() ?? 1,
  unlockedAt: json['unlockedAt'] == null
      ? null
      : DateTime.parse(json['unlockedAt'] as String),
  type: json['type'] as String?,
);

Map<String, dynamic> _$AchievementToJson(_Achievement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'category': instance.category,
      'points': instance.points,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'progress': instance.progress,
      'target': instance.target,
      'reward': instance.reward,
      'isVisible': instance.isVisible,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
      'isUnlocked': instance.isUnlocked,
      'currentProgress': instance.currentProgress,
      'targetValue': instance.targetValue,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
      'type': instance.type,
    };
