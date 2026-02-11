// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      type: $enumDecodeNullable(_$AchievementTypeEnumMap, json['type']) ??
          AchievementType.progress,
      specificType: $enumDecodeNullable(
          _$SpecificAchievementTypeEnumMap, json['specific_type']),
      targetProgress: (json['target_progress'] as num?)?.toInt(),
      currentProgress: (json['current_progress'] as num?)?.toInt() ?? 0,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      isVisible: json['is_visible'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] == null
          ? null
          : DateTime.parse(json['unlocked_at'] as String),
      reward: json['reward'] as String?,
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'specific_type': _$SpecificAchievementTypeEnumMap[instance.specificType],
      'target_progress': instance.targetProgress,
      'current_progress': instance.currentProgress,
      'is_unlocked': instance.isUnlocked,
      'is_visible': instance.isVisible,
      'unlocked_at': instance.unlockedAt?.toIso8601String(),
      'reward': instance.reward,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.progress: 'progress',
  AchievementType.milestone: 'milestone',
  AchievementType.challenge: 'challenge',
  AchievementType.seasonal: 'seasonal',
};

const _$SpecificAchievementTypeEnumMap = {
  SpecificAchievementType.dailyLogin: 'daily_login',
  SpecificAchievementType.weeklyLogin: 'weekly_login',
  SpecificAchievementType.monthlyLogin: 'monthly_login',
  SpecificAchievementType.firstOutfitCreated: 'first_outfit_created',
  SpecificAchievementType.tenOutfitsCreated: 'ten_outfits_created',
  SpecificAchievementType.hundredOutfitsCreated: 'hundred_outfits_created',
  SpecificAchievementType.firstRecommendationLiked:
      'first_recommendation_liked',
  SpecificAchievementType.tenRecommendationsLiked: 'ten_recommendations_liked',
  SpecificAchievementType.hundredRecommendationsLiked:
      'hundred_recommendations_liked',
  SpecificAchievementType.firstWardrobeItemAdded: 'first_wardrobe_item_added',
  SpecificAchievementType.tenWardrobeItemsAdded: 'ten_wardrobe_items_added',
  SpecificAchievementType.hundredWardrobeItemsAdded:
      'hundred_wardrobe_items_added',
  SpecificAchievementType.firstShare: 'first_share',
  SpecificAchievementType.tenShares: 'ten_shares',
  SpecificAchievementType.hundredShares: 'hundred_shares',
  SpecificAchievementType.weatherExpert: 'weather_expert',
  SpecificAchievementType.styleGuru: 'style_guru',
  SpecificAchievementType.communityMember: 'community_member',
  SpecificAchievementType.seasonalWardrobe: 'seasonal_wardrobe',
  SpecificAchievementType.perfectMatch: 'perfect_match',
};
