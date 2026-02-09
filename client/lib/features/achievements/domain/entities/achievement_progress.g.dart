// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementProgressImpl _$$AchievementProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$AchievementProgressImpl(
      achievementId: json['achievementId'] as String,
      currentProgress: (json['currentProgress'] as num).toInt(),
      maxProgress: (json['maxProgress'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$AchievementProgressImplToJson(
        _$AchievementProgressImpl instance) =>
    <String, dynamic>{
      'achievementId': instance.achievementId,
      'currentProgress': instance.currentProgress,
      'maxProgress': instance.maxProgress,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
    };
