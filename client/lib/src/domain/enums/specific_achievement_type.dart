import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum SpecificAchievementType {
  dailyLogin('daily_login'),
  weeklyLogin('weekly_login'),
  monthlyLogin('monthly_login'),
  firstOutfitCreated('first_outfit_created'),
  tenOutfitsCreated('ten_outfits_created'),
  hundredOutfitsCreated('hundred_outfits_created'),
  firstRecommendationLiked('first_recommendation_liked'),
  tenRecommendationsLiked('ten_recommendations_liked'),
  hundredRecommendationsLiked('hundred_recommendations_liked'),
  firstWardrobeItemAdded('first_wardrobe_item_added'),
  tenWardrobeItemsAdded('ten_wardrobe_items_added'),
  hundredWardrobeItemsAdded('hundred_wardrobe_items_added'),
  firstShare('first_share'),
  tenShares('ten_shares'),
  hundredShares('hundred_shares'),
  weatherExpert('weather_expert'),
  styleGuru('style_guru'),
  communityMember('community_member'),
  seasonalWardrobe('seasonal_wardrobe'),
  perfectMatch('perfect_match');

  const SpecificAchievementType(this.value);
  final String value;
}
