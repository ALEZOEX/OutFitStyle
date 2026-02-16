import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/enums/clothing_category.dart';
import '../../domain/enums/clothing_season.dart';
import '../../domain/enums/clothing_weather.dart';
import '../../domain/enums/outfit_occasion.dart';
import '../../domain/enums/outfit_season.dart';
import '../../domain/enums/outfit_weather.dart';

/// Конвертер для списков строк в JSON
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      // Fallback для старого формата (через запятую)
      return fromDb.split(',').where((s) => s.isNotEmpty).toList();
    }
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

/// Конвертер для ClothingCategory
class ClothingCategoryConverter extends TypeConverter<ClothingCategory, String> {
  const ClothingCategoryConverter();

  @override
  ClothingCategory fromSql(String fromDb) {
    return ClothingCategory.fromValue(fromDb);
  }

  @override
  String toSql(ClothingCategory value) {
    return value.value;
  }
}

/// Конвертер для списков ClothingSeason
class ClothingSeasonListConverter
    extends TypeConverter<List<ClothingSeason>, String> {
  const ClothingSeasonListConverter();

  @override
  List<ClothingSeason> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded
          .map((e) => ClothingSeason.fromValue(e.toString()))
          .toList();
    } catch (_) {
      return fromDb.split(',').map(ClothingSeason.fromValue).toList();
    }
  }

  @override
  String toSql(List<ClothingSeason> value) {
    return jsonEncode(value.map((e) => e.value).toList());
  }
}

/// Конвертер для списков ClothingWeather
class ClothingWeatherListConverter
    extends TypeConverter<List<ClothingWeather>, String> {
  const ClothingWeatherListConverter();

  @override
  List<ClothingWeather> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded
          .map((e) => ClothingWeather.fromValue(e.toString()))
          .toList();
    } catch (_) {
      return fromDb.split(',').map(ClothingWeather.fromValue).toList();
    }
  }

  @override
  String toSql(List<ClothingWeather> value) {
    return jsonEncode(value.map((e) => e.value).toList());
  }
}

/// Конвертер для списков OutfitOccasion
class OutfitOccasionListConverter
    extends TypeConverter<List<OutfitOccasion>, String> {
  const OutfitOccasionListConverter();

  @override
  List<OutfitOccasion> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded
          .map((e) => OutfitOccasion.fromValue(e.toString()))
          .toList();
    } catch (_) {
      return fromDb.split(',').map(OutfitOccasion.fromValue).toList();
    }
  }

  @override
  String toSql(List<OutfitOccasion> value) {
    return jsonEncode(value.map((e) => e.value).toList());
  }
}

/// Конвертер для списков OutfitSeason
class OutfitSeasonListConverter
    extends TypeConverter<List<OutfitSeason>, String> {
  const OutfitSeasonListConverter();

  @override
  List<OutfitSeason> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded
          .map((e) => OutfitSeason.fromValue(e.toString()))
          .toList();
    } catch (_) {
      return fromDb.split(',').map(OutfitSeason.fromValue).toList();
    }
  }

  @override
  String toSql(List<OutfitSeason> value) {
    return jsonEncode(value.map((e) => e.value).toList());
  }
}

/// Конвертер для списков OutfitWeather
class OutfitWeatherListConverter
    extends TypeConverter<List<OutfitWeather>, String> {
  const OutfitWeatherListConverter();

  @override
  List<OutfitWeather> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded
          .map((e) => OutfitWeather.fromValue(e.toString()))
          .toList();
    } catch (_) {
      return fromDb.split(',').map(OutfitWeather.fromValue).toList();
    }
  }

  @override
  String toSql(List<OutfitWeather> value) {
    return jsonEncode(value.map((e) => e.value).toList());
  }
}

/// Конвертер для списков int (clothing_item_ids)
class IntListConverter extends TypeConverter<List<int>, String> {
  const IntListConverter();

  @override
  List<int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    try {
      final decoded = jsonDecode(fromDb) as List<dynamic>;
      return decoded.map((e) => (e as num).toInt()).toList();
    } catch (_) {
      return fromDb
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? 0)
          .toList();
    }
  }

  @override
  String toSql(List<int> value) {
    return jsonEncode(value);
  }
}

/// Конвертер для `Map<String, dynamic>` (metadata)
class MetadataConverter extends TypeConverter<Map<String, dynamic>, String> {
  const MetadataConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    try {
      return jsonDecode(fromDb) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return jsonEncode(value);
  }
}

/// Конвертер для DateTime (хранится как millisecondsSinceEpoch)
class DateTimeConverter extends TypeConverter<DateTime, int> {
  const DateTimeConverter();

  @override
  DateTime fromSql(int fromDb) {
    return DateTime.fromMillisecondsSinceEpoch(fromDb);
  }

  @override
  int toSql(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}

/// Конвертер для DateTime? (nullable)
class NullableDateTimeConverter
    extends TypeConverter<DateTime?, int?> {
  const NullableDateTimeConverter();

  @override
  DateTime? fromSql(int? fromDb) {
    if (fromDb == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(fromDb);
  }

  @override
  int? toSql(DateTime? value) {
    return value?.millisecondsSinceEpoch;
  }
}
