// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clothing_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClothingItem _$ClothingItemFromJson(Map<String, dynamic> json) =>
    _ClothingItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      category:
          $enumDecodeNullable(_$ClothingCategoryEnumMap, json['category']) ??
          ClothingCategory.tops,
      color: json['color'] as String?,
      brand: json['brand'] as String?,
      material: json['material'] as String?,
      seasons:
          (json['seasons'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ClothingSeasonEnumMap, e))
              .toList() ??
          const [],
      weatherConditions:
          (json['weatherConditions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ClothingWeatherEnumMap, e))
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      occasions:
          (json['occasions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      timesWorn: (json['timesWorn'] as num?)?.toInt() ?? 0,
      comfortRating: (json['comfortRating'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
      addedDate:
          json['addedDate'] == null
              ? null
              : DateTime.parse(json['addedDate'] as String),
      lastWornDate:
          json['lastWornDate'] == null
              ? null
              : DateTime.parse(json['lastWornDate'] as String),
      price: (json['price'] as num?)?.toDouble(),
      size: json['size'] as String?,
    );

Map<String, dynamic> _$ClothingItemToJson(
  _ClothingItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'tags': instance.tags,
  'category': _$ClothingCategoryEnumMap[instance.category]!,
  'color': instance.color,
  'brand': instance.brand,
  'material': instance.material,
  'seasons': instance.seasons.map((e) => _$ClothingSeasonEnumMap[e]!).toList(),
  'weatherConditions':
      instance.weatherConditions
          .map((e) => _$ClothingWeatherEnumMap[e]!)
          .toList(),
  'isFavorite': instance.isFavorite,
  'isArchived': instance.isArchived,
  'occasions': instance.occasions,
  'usageCount': instance.usageCount,
  'timesWorn': instance.timesWorn,
  'comfortRating': instance.comfortRating,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'addedDate': instance.addedDate?.toIso8601String(),
  'lastWornDate': instance.lastWornDate?.toIso8601String(),
  'price': instance.price,
  'size': instance.size,
};

const _$ClothingCategoryEnumMap = {
  ClothingCategory.tops: 'tops',
  ClothingCategory.bottoms: 'bottoms',
  ClothingCategory.dresses: 'dresses',
  ClothingCategory.outerwear: 'outerwear',
  ClothingCategory.shoes: 'shoes',
  ClothingCategory.accessories: 'accessories',
  ClothingCategory.bags: 'bags',
  ClothingCategory.sportswear: 'sportswear',
};

const _$ClothingSeasonEnumMap = {
  ClothingSeason.spring: 'spring',
  ClothingSeason.summer: 'summer',
  ClothingSeason.autumn: 'autumn',
  ClothingSeason.winter: 'winter',
  ClothingSeason.allSeason: 'all_season',
};

const _$ClothingWeatherEnumMap = {
  ClothingWeather.sunny: 'sunny',
  ClothingWeather.cloudy: 'cloudy',
  ClothingWeather.rainy: 'rainy',
  ClothingWeather.snowy: 'snowy',
  ClothingWeather.windy: 'windy',
  ClothingWeather.hot: 'hot',
  ClothingWeather.cold: 'cold',
  ClothingWeather.mild: 'mild',
};
