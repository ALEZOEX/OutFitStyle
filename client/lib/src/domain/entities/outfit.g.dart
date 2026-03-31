// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outfit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Outfit _$OutfitFromJson(Map<String, dynamic> json) => _Outfit(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  imageUrl: json['image_url'] as String?,
  clothingItemIds:
      (json['clothing_item_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  occasions:
      (json['occasions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$OutfitOccasionEnumMap, e))
          .toList() ??
      const [],
  weatherConditions:
      (json['weather_conditions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$OutfitWeatherEnumMap, e))
          .toList() ??
      const [],
  seasons:
      (json['seasons'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$OutfitSeasonEnumMap, e))
          .toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isFavorite: json['is_favorite'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  timesWorn: (json['timesWorn'] as num?)?.toInt() ?? 0,
  comfortRating: (json['comfortRating'] as num?)?.toDouble() ?? 0.0,
  addedDate: json['addedDate'] == null
      ? null
      : DateTime.parse(json['addedDate'] as String),
);

Map<String, dynamic> _$OutfitToJson(_Outfit instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'clothing_item_ids': instance.clothingItemIds,
  'occasions': instance.occasions
      .map((e) => _$OutfitOccasionEnumMap[e]!)
      .toList(),
  'weather_conditions': instance.weatherConditions
      .map((e) => _$OutfitWeatherEnumMap[e]!)
      .toList(),
  'seasons': instance.seasons.map((e) => _$OutfitSeasonEnumMap[e]!).toList(),
  'tags': instance.tags,
  'is_favorite': instance.isFavorite,
  'created_at': instance.createdAt?.toIso8601String(),
  'timesWorn': instance.timesWorn,
  'comfortRating': instance.comfortRating,
  'addedDate': instance.addedDate?.toIso8601String(),
};

const _$OutfitOccasionEnumMap = {
  OutfitOccasion.casual: 'casual',
  OutfitOccasion.formal: 'formal',
  OutfitOccasion.business: 'business',
  OutfitOccasion.party: 'party',
  OutfitOccasion.dateNight: 'date_night',
  OutfitOccasion.wedding: 'wedding',
  OutfitOccasion.funeral: 'funeral',
  OutfitOccasion.interview: 'interview',
  OutfitOccasion.vacation: 'vacation',
  OutfitOccasion.exercise: 'exercise',
  OutfitOccasion.shopping: 'shopping',
  OutfitOccasion.school: 'school',
  OutfitOccasion.work: 'work',
  OutfitOccasion.sportingEvent: 'sporting_event',
  OutfitOccasion.outdoorActivity: 'outdoor_activity',
  OutfitOccasion.home: 'home',
};

const _$OutfitWeatherEnumMap = {
  OutfitWeather.sunny: 'sunny',
  OutfitWeather.cloudy: 'cloudy',
  OutfitWeather.rainy: 'rainy',
  OutfitWeather.snowy: 'snowy',
  OutfitWeather.windy: 'windy',
  OutfitWeather.hot: 'hot',
  OutfitWeather.cold: 'cold',
  OutfitWeather.mild: 'mild',
};

const _$OutfitSeasonEnumMap = {
  OutfitSeason.spring: 'spring',
  OutfitSeason.summer: 'summer',
  OutfitSeason.autumn: 'autumn',
  OutfitSeason.winter: 'winter',
  OutfitSeason.allSeason: 'all_season',
};
