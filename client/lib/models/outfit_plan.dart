import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart';

import 'user_wardrobe.dart';

/// Model for a planned outfit on a specific date
class OutfitPlan {
  final int id;
  final DateTime date;

  /// Полный список вещей (обогащённые WardrobeItem, если есть).
  final List<WardrobeItem> items;
  final String? notes;
  final String? weatherCondition;
  final double? temperature;

  OutfitPlan({
    required this.id,
    required this.date,
    required this.items,
    this.notes,
    this.weatherCondition,
    this.temperature,
  });

  /// Create OutfitPlan from JSON map.
  ///
  /// Поддерживает два возможных формата:
  /// 1) API отдает полный список вещей:
  ///    {
  ///      "id": 1,
  ///      "date": "2025-11-20T00:00:00Z",
  ///      "items": [ { WardrobeItem }, ... ],
  ///      "notes": "...",
  ///      "weather_condition": "...",
  ///      "temperature": 12.3
  ///    }
  ///
  /// 2) API отдает только item_ids (как сейчас делает Go-бэкенд):
  ///    {
  ///      "id": 1,
  ///      "date": "2025-11-20T00:00:00Z",
  ///      "item_ids": [1, 2, 3],
  ///      "notes": "..."
  ///    }
  factory OutfitPlan.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final date = DateTime.parse(json['date'] as String);

    // Пытаемся прочитать items как полноценные объекты
    List<WardrobeItem> items = [];
    final rawItems = json['items'];

    if (rawItems is List) {
      items = rawItems
          .whereType<Map<String, dynamic>>()
          .map((item) => WardrobeItem.fromJson(item))
          .toList();
    } else if (json['item_ids'] is List) {
      // Фолбэк: есть только item_ids, строим простые заглушки
      final ids = (json['item_ids'] as List)
          .where((e) => e != null)
          .map((e) => e as int)
          .toList();

      items = ids
          .map(
            (id) => WardrobeItem(
              id: id,
              customName: 'Вещь $id',
              customIcon: '👕',
            ),
          )
          .toList();
    }

    final notes = json['notes'] as String?;
    final weatherCondition = json['weather_condition'] as String?;
    final temperature = (json['temperature'] is num)
        ? (json['temperature'] as num).toDouble()
        : null;

    return OutfitPlan(
      id: id,
      date: date,
      items: items,
      notes: notes,
      weatherCondition: weatherCondition,
      temperature: temperature,
    );
  }

  /// Convert OutfitPlan to JSON map.
  ///
  /// Для бэкенда важнее всего:
  /// - id (если есть)
  /// - date
  /// - item_ids (список ID вещей)
  /// - notes
  ///
  /// Поэтому в JSON кладём **item_ids**, а не список полных WardrobeItem.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'item_ids': items.map((item) => item.id).toList(),
      'notes': notes,
      'weather_condition': weatherCondition,
      'temperature': temperature,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OutfitPlan &&
        other.id == id &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        listEquals(other.items, items);
  }

  @override
  int get hashCode => Object.hash(
        id,
        date.year,
        date.month,
        date.day,
        const DeepCollectionEquality().hash(items),
      );
}
