// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WardrobeItem _$WardrobeItemFromJson(Map<String, dynamic> json) =>
    _WardrobeItem(
      id: json['id'] as String?,
      name: json['name'] as String?,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      size: json['size'] as String?,
      imageUrl: json['imageUrl'] as String?,
      iconEmoji: json['iconEmoji'] as String?,
      blurHash: json['blurHash'] as String?,
      minTemp: (json['min_temp'] as num?)?.toDouble(),
      maxTemp: (json['max_temp'] as num?)?.toDouble(),
      warmthLevel: (json['warmth_level'] as num?)?.toInt(),
      rainOk: json['rain_ok'] as bool?,
      snowOk: json['snow_ok'] as bool?,
      windOk: json['wind_ok'] as bool?,
      usage: (json['usage'] as num?)?.toInt(),
      materials:
          (json['materials'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      gender: json['gender'] as String?,
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      localImagePath: json['localImagePath'] as String?,
      style: json['style'] as String?,
      isFavorite: json['is_favorite'] as bool?,
      isArchived: json['is_archived'] as bool?,
      season: json['season'] as String?,
      serverId: json['server_id'] as String?,
      dirty: json['dirty'] as bool?,
      lastSyncedAt:
          json['last_synced_at'] == null
              ? null
              : DateTime.parse(json['last_synced_at'] as String),
    );

Map<String, dynamic> _$WardrobeItemToJson(_WardrobeItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'brand': instance.brand,
      'color': instance.color,
      'size': instance.size,
      'imageUrl': instance.imageUrl,
      'iconEmoji': instance.iconEmoji,
      'blurHash': instance.blurHash,
      'min_temp': instance.minTemp,
      'max_temp': instance.maxTemp,
      'warmth_level': instance.warmthLevel,
      'rain_ok': instance.rainOk,
      'snow_ok': instance.snowOk,
      'wind_ok': instance.windOk,
      'usage': instance.usage,
      'materials': instance.materials,
      'gender': instance.gender,
      'fit': instance.fit,
      'pattern': instance.pattern,
      'localImagePath': instance.localImagePath,
      'style': instance.style,
      'is_favorite': instance.isFavorite,
      'is_archived': instance.isArchived,
      'season': instance.season,
      'server_id': instance.serverId,
      'dirty': instance.dirty,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
    };
