import '../data/local/app_database.dart';

class OutfitBuilder {
  /// Собираем финальный список линий образа:
  /// - если по category есть override (WardrobeEntry) — подставляем его
  /// - иначе оставляем оригинал из recommendation outfit_data
  static List<Map<String, dynamic>> buildFinalLines({
    required List<Map<String, dynamic>> originalLines,
    required Map<String, WardrobeEntry> overridesByCategory,
  }) {
    final out = <Map<String, dynamic>>[];

    for (final line in originalLines) {
      final cat = (line['category'] ?? '').toString();
      final override = overridesByCategory[cat];

      if (override != null) {
        out.add(_mapWardrobeEntryToOutfitLine(override));
      } else {
        out.add(Map<String, dynamic>.from(line));
      }
    }

    // Если вдруг override есть по категории, которой не было в оригинале — добавим в конец
    for (final kv in overridesByCategory.entries) {
      final cat = kv.key;
      final exists = out.any((e) => (e['category'] ?? '').toString() == cat);
      if (!exists) out.add(_mapWardrobeEntryToOutfitLine(kv.value));
    }

    return out;
  }

  static Map<String, dynamic> buildOutfitData({
    required List<Map<String, dynamic>> lines,
  }) {
    return <String, dynamic>{
      'outfit': lines,
    };
  }

  static Map<String, dynamic> _mapWardrobeEntryToOutfitLine(WardrobeEntry w) {
    return <String, dynamic>{
      'id': w.id,
      'name': w.name,
      'category': w.category,
      'subcategory': w.subcategory,
      'icon_emoji': w.iconEmoji,
      'source': 'wardrobe',
      'is_owned': true,
      // можно расширять позже:
      'image_url': w.imageUrl,
    };
  }
}
