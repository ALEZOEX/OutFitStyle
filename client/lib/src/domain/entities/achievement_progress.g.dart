// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AchievementProgress _$AchievementProgressFromJson(Map<String, dynamic> json) =>
    _AchievementProgress(
      achievementId: json['achievementId'] as String,
      userId: json['userId'] as String,
      currentProgress: (json['currentProgress'] as num).toInt(),
      targetProgress: (json['targetProgress'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AchievementProgressToJson(
  _AchievementProgress instance,
) => <String, dynamic>{
  'achievementId': instance.achievementId,
  'userId': instance.userId,
  'currentProgress': instance.currentProgress,
  'targetProgress': instance.targetProgress,
  'isCompleted': instance.isCompleted,
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
