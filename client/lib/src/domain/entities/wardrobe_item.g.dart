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
      minTemp: (json['minTemp'] as num?)?.toDouble(),
      maxTemp: (json['maxTemp'] as num?)?.toDouble(),
      warmthLevel: (json['warmthLevel'] as num?)?.toInt(),
      rainOk: json['rainOk'] as bool?,
      snowOk: json['snowOk'] as bool?,
      windOk: json['windOk'] as bool?,
      usage: (json['usage'] as num?)?.toInt(),
      materials: (json['materials'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gender: json['gender'] as String?,
      fit: json['fit'] as String?,
      pattern: json['pattern'] as String?,
      localImagePath: json['localImagePath'] as String?,
      style: json['style'] as String?,
      isFavorite: json['isFavorite'] as bool?,
      isArchived: json['isArchived'] as bool?,
      season: json['season'] as String?,
      serverId: json['serverId'] as String?,
      dirty: json['dirty'] as bool?,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
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
      'minTemp': instance.minTemp,
      'maxTemp': instance.maxTemp,
      'warmthLevel': instance.warmthLevel,
      'rainOk': instance.rainOk,
      'snowOk': instance.snowOk,
      'windOk': instance.windOk,
      'usage': instance.usage,
      'materials': instance.materials,
      'gender': instance.gender,
      'fit': instance.fit,
      'pattern': instance.pattern,
      'localImagePath': instance.localImagePath,
      'style': instance.style,
      'isFavorite': instance.isFavorite,
      'isArchived': instance.isArchived,
      'season': instance.season,
      'serverId': instance.serverId,
      'dirty': instance.dirty,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };
