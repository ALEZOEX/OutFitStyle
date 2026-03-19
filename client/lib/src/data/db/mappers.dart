import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/wardrobe_item.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/entities/outfit_item.dart';
import '../../domain/enums/outfit_occasion.dart';
import '../../domain/enums/outfit_season.dart';
import '../../domain/enums/outfit_weather.dart';

import 'wardrobe_database.dart';

/// Маппер для конвертации между DbClothingItem и WardrobeItem
class WardrobeItemMapper {
  /// Конвертировать DbClothingItem в WardrobeItem
  static WardrobeItem toEntity(DbClothingItem db) {
    return WardrobeItem(
      id: db.serverId ?? db.id.toString(),
      serverId: db.serverId,
      name: db.name,
      category: db.category,
      brand: db.brand,
      color: db.color,
      imageUrl: db.imageUrl,
      isFavorite: db.isFavorite,
      isArchived: db.isArchived,
      size: db.size,
      // Поля из ClothingItem - мапим на usage
      usage: db.usageCount,
      lastSyncedAt:
          db.lastSyncedAt != null
              ? DateTime.fromMillisecondsSinceEpoch(db.lastSyncedAt!)
              : null,
      dirty: db.dirty,
      // Дополнительные поля из tags JSON
      season: _parseSeasonFromTags(_parseStringList(db.tags)),
      style: _parseStyleFromTags(_parseStringList(db.tags)),
      fit: _parseFitFromTags(_parseStringList(db.tags)),
      pattern: _parsePatternFromTags(_parseStringList(db.tags)),
      gender: _parseGenderFromTags(_parseStringList(db.tags)),
      // Погодные условия из weather_conditions
      rainOk: _parseStringList(db.weatherConditions).contains('rainy'),
      snowOk: _parseStringList(db.weatherConditions).contains('snowy'),
      windOk: _parseStringList(db.weatherConditions).contains('windy'),
      minTemp: _parseMinTempFromWeather(_parseStringList(db.weatherConditions)),
      maxTemp: _parseMaxTempFromWeather(_parseStringList(db.weatherConditions)),
      warmthLevel: _parseWarmthLevelFromWeather(
        _parseStringList(db.weatherConditions),
      ),
      // Материалы из material поля
      materials: db.material != null ? [db.material!] : [],
      // Icon emoji и blurHash пока не поддерживаются
      iconEmoji: null,
      blurHash: null,
      localImagePath: null,
      subcategory: null,
    );
  }

  /// Конвертировать WardrobeItem в ClothingItemsCompanion для вставки
  static ClothingItemsCompanion toCompanionForInsert(
    WardrobeItem entity, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    return ClothingItemsCompanion(
      externalId: Value(entity.id),
      name: Value(entity.name ?? ''),
      description: const Value(null),
      imageUrl: Value(entity.imageUrl),
      category: Value(entity.category ?? 'tops'),
      tags: Value(_buildTags(entity)),
      color: Value(entity.color),
      brand: Value(entity.brand),
      material: Value(_buildMaterial(entity)),
      seasons: Value(_buildSeasons(entity)),
      weatherConditions: Value(_buildWeatherConditions(entity)),
      occasions: const Value('[]'),
      isFavorite: Value(entity.isFavorite ?? false),
      isArchived: Value(entity.isArchived ?? false),
      timesWorn: const Value(0),
      comfortRating: const Value(0.0),
      addedDate: Value(currentTime.millisecondsSinceEpoch),
      createdAt: Value(currentTime.millisecondsSinceEpoch),
      updatedAt: Value(currentTime.millisecondsSinceEpoch),
      lastWornDate: const Value(null),
      price: const Value(null),
      size: Value(entity.size),
      usageCount: Value(entity.usage ?? 0),
      serverId: Value(entity.serverId),
      dirty: Value(entity.dirty ?? true),
      lastSyncedAt: Value(entity.lastSyncedAt?.millisecondsSinceEpoch),
    );
  }

  /// Конвертировать WardrobeItem в ClothingItemsCompanion для обновления
  static ClothingItemsCompanion toCompanionForUpdate(
    WardrobeItem entity, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    return ClothingItemsCompanion(
      externalId: Value(entity.id),
      name: Value(entity.name ?? ''),
      description: const Value(null),
      imageUrl: Value(entity.imageUrl),
      category: Value(entity.category ?? 'tops'),
      tags: Value(_buildTags(entity)),
      color: Value(entity.color),
      brand: Value(entity.brand),
      material: Value(_buildMaterial(entity)),
      seasons: Value(_buildSeasons(entity)),
      weatherConditions: Value(_buildWeatherConditions(entity)),
      occasions: const Value('[]'),
      isFavorite: Value(entity.isFavorite ?? false),
      isArchived: Value(entity.isArchived ?? false),
      timesWorn: const Value(0),
      comfortRating: const Value(0.0),
      updatedAt: Value(currentTime.millisecondsSinceEpoch),
      size: Value(entity.size),
      usageCount: Value(entity.usage ?? 0),
      dirty: const Value(true),
    );
  }

  static String _buildTags(WardrobeItem item) {
    final tags = <String>[];
    if (item.style != null && item.style!.isNotEmpty) {
      tags.add('style:${item.style}');
    }
    if (item.fit != null && item.fit!.isNotEmpty) {
      tags.add('fit:${item.fit}');
    }
    if (item.pattern != null && item.pattern!.isNotEmpty) {
      tags.add('pattern:${item.pattern}');
    }
    if (item.gender != null && item.gender!.isNotEmpty) {
      tags.add('gender:${item.gender}');
    }
    return _toJsonArray(tags);
  }

  static String _buildSeasons(WardrobeItem item) {
    final seasons = <String>[];
    final season = item.season;
    if (season != null && season.isNotEmpty) {
      seasons.add(season);
    }
    return _toJsonArray(seasons);
  }

  static String _buildWeatherConditions(WardrobeItem item) {
    final conditions = <String>[];
    if (item.rainOk == true) conditions.add('rainy');
    if (item.snowOk == true) conditions.add('snowy');
    if (item.windOk == true) conditions.add('windy');

    // Температурные условия
    final minTemp = item.minTemp;
    final maxTemp = item.maxTemp;
    if (maxTemp != null && maxTemp > 30) conditions.add('hot');
    if (minTemp != null && minTemp < 10) conditions.add('cold');
    if ((minTemp == null || minTemp >= 15) &&
        (maxTemp == null || maxTemp <= 25)) {
      conditions.add('mild');
    }

    return _toJsonArray(conditions);
  }

  static String? _buildMaterial(WardrobeItem item) {
    final materials = item.materials;
    if (materials != null && materials.isNotEmpty) {
      return materials.first;
    }
    return null;
  }

  static String _toJsonArray(List<String> list) {
    if (list.isEmpty) return '[]';
    return '[${list.map((e) => '"$e"').join(',')}]';
  }

  static List<String> _parseStringList(String json) {
    if (json == '[]' || json.isEmpty) return [];
    try {
      final decoded = (jsonDecode(json) as List<dynamic>);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return json.split(',').where((s) => s.isNotEmpty).toList();
    }
  }

  // Парсинг тегов
  static String? _parseSeasonFromTags(List<String> tags) {
    for (final tag in tags) {
      if (tag.startsWith('season:')) {
        return tag.substring(7);
      }
    }
    return null;
  }

  static String? _parseStyleFromTags(List<String> tags) {
    for (final tag in tags) {
      if (tag.startsWith('style:')) {
        return tag.substring(6);
      }
    }
    return null;
  }

  static String? _parseFitFromTags(List<String> tags) {
    for (final tag in tags) {
      if (tag.startsWith('fit:')) {
        return tag.substring(4);
      }
    }
    return null;
  }

  static String? _parsePatternFromTags(List<String> tags) {
    for (final tag in tags) {
      if (tag.startsWith('pattern:')) {
        return tag.substring(8);
      }
    }
    return null;
  }

  static String? _parseGenderFromTags(List<String> tags) {
    for (final tag in tags) {
      if (tag.startsWith('gender:')) {
        return tag.substring(7);
      }
    }
    return null;
  }

  static double? _parseMinTempFromWeather(List<String> weather) {
    if (weather.contains('cold')) return 0;
    if (weather.contains('mild')) return 15;
    return null;
  }

  static double? _parseMaxTempFromWeather(List<String> weather) {
    if (weather.contains('hot')) return 40;
    if (weather.contains('mild')) return 25;
    return null;
  }

  static int _parseWarmthLevelFromWeather(List<String> weather) {
    if (weather.contains('cold') || weather.contains('snowy')) return 3;
    if (weather.contains('mild')) return 2;
    return 1;
  }
}

/// Маппер для конвертации между DbOutfit и Outfit
class OutfitMapper {
  /// Конвертировать DbOutfit в Outfit
  static Outfit toEntity(DbOutfit db) {
    return Outfit(
      id: db.id,
      name: db.name,
      description: db.description,
      imageUrl: db.imageUrl,
      clothingItemIds: _parseIntList(db.clothingItemIds),
      occasions: _parseOccasions(db.occasions),
      weatherConditions: _parseWeatherConditions(db.weatherConditions),
      seasons: _parseSeasons(db.seasons),
      tags: _parseStringList(db.tags),
      isFavorite: db.isFavorite,
      createdAt: DateTime.fromMillisecondsSinceEpoch(db.createdAt),
      timesWorn: db.timesWorn,
      comfortRating: db.comfortRating.toDouble(),
      addedDate: DateTime.fromMillisecondsSinceEpoch(db.addedDate),
    );
  }

  /// Конвертировать Outfit в OutfitsCompanion для вставки
  static OutfitsCompanion toCompanionForInsert(Outfit entity, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return OutfitsCompanion(
      externalId: const Value(null),
      name: Value(entity.name ?? ''),
      description: Value(entity.description),
      imageUrl: Value(entity.imageUrl),
      clothingItemIds: Value(_encodeIntList(entity.clothingItemIds)),
      isFavorite: Value(entity.isFavorite),
      timesWorn: Value(entity.timesWorn),
      comfortRating: Value(entity.comfortRating.toDouble()),
      tags: Value(_encodeStringList(entity.tags)),
      occasions: Value(_encodeOccasions(entity.occasions)),
      weatherConditions: Value(
        _encodeWeatherConditions(entity.weatherConditions),
      ),
      seasons: Value(_encodeSeasons(entity.seasons)),
      addedDate: Value(currentTime.millisecondsSinceEpoch),
      createdAt: Value(currentTime.millisecondsSinceEpoch),
      updatedAt: Value(currentTime.millisecondsSinceEpoch),
      serverId: const Value(null),
      dirty: const Value(true),
      lastSyncedAt: const Value(null),
    );
  }

  /// Конвертировать Outfit в OutfitsCompanion для обновления
  static OutfitsCompanion toCompanionForUpdate(Outfit entity, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    return OutfitsCompanion(
      name: Value(entity.name ?? ''),
      description: Value(entity.description),
      imageUrl: Value(entity.imageUrl),
      clothingItemIds: Value(_encodeIntList(entity.clothingItemIds)),
      isFavorite: Value(entity.isFavorite),
      timesWorn: Value(entity.timesWorn),
      comfortRating: Value(entity.comfortRating.toDouble()),
      tags: Value(_encodeStringList(entity.tags)),
      occasions: Value(_encodeOccasions(entity.occasions)),
      weatherConditions: Value(
        _encodeWeatherConditions(entity.weatherConditions),
      ),
      seasons: Value(_encodeSeasons(entity.seasons)),
      updatedAt: Value(currentTime.millisecondsSinceEpoch),
      dirty: const Value(true),
    );
  }

  static List<String> _parseStringList(String json) {
    if (json == '[]' || json.isEmpty) return [];
    try {
      final decoded = (jsonDecode(json) as List<dynamic>);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return json.split(',').where((s) => s.isNotEmpty).toList();
    }
  }

  static List<OutfitOccasion> _parseOccasions(String json) {
    final list = _parseStringList(json);
    return list.map(OutfitOccasion.fromValue).toList();
  }

  static List<OutfitWeather> _parseWeatherConditions(String json) {
    final list = _parseStringList(json);
    return list.map(OutfitWeather.fromValue).toList();
  }

  static List<OutfitSeason> _parseSeasons(String json) {
    final list = _parseStringList(json);
    return list.map(OutfitSeason.fromValue).toList();
  }

  static List<int> _parseIntList(String json) {
    if (json == '[]' || json.isEmpty) return [];
    try {
      final decoded = (jsonDecode(json) as List<dynamic>);
      return decoded.map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return json
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? 0)
          .toList();
    }
  }

  static String _encodeStringList(List<String> list) {
    if (list.isEmpty) return '[]';
    return '[${list.map((e) => '"$e"').join(',')}]';
  }

  static String _encodeIntList(List<int> list) {
    if (list.isEmpty) return '[]';
    return '[${list.join(',')}]';
  }

  static String _encodeOccasions(List<OutfitOccasion> occasions) {
    return _encodeStringList(occasions.map((e) => e.value).toList());
  }

  static String _encodeWeatherConditions(List<OutfitWeather> weather) {
    return _encodeStringList(weather.map((e) => e.value).toList());
  }

  static String _encodeSeasons(List<OutfitSeason> seasons) {
    return _encodeStringList(seasons.map((e) => e.value).toList());
  }
}

/// Маппер для конвертации между DbOutfitItem и OutfitItem
class OutfitItemMapper {
  /// Конвертировать DbOutfitItem в OutfitItem
  static OutfitItem toEntity(DbOutfitItem db) {
    return OutfitItem(
      id: db.id,
      outfitId: db.outfitId,
      clothingItemId: db.clothingItemId,
      sortOrder: db.sortOrder,
      isPrimary: db.isPrimary,
      metadata: _parseMetadata(db.metadata),
    );
  }

  /// Конвертировать OutfitItem в OutfitItemsCompanion
  static OutfitItemsCompanion toCompanion(OutfitItem entity) {
    return OutfitItemsCompanion(
      outfitId: Value(entity.outfitId ?? 0),
      clothingItemId: Value(entity.clothingItemId ?? 0),
      sortOrder: Value(entity.sortOrder),
      isPrimary: Value(entity.isPrimary),
      metadata: Value(_encodeMetadata(entity.metadata)),
    );
  }

  static Map<String, dynamic> _parseMetadata(String json) {
    if (json == '{}' || json.isEmpty) return {};
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) return '{}';
    return jsonEncode(metadata);
  }
}
