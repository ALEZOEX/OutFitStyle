import 'package:flutter/foundation.dart';
import '../models/user_wardrobe.dart';
import 'package:collection/collection.dart';

/// Model for a planned outfit on a specific date
class OutfitPlan {
  final int id;
  final DateTime date;
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

  /// Create OutfitPlan from JSON map
  factory OutfitPlan.fromJson(Map<String, dynamic> json) {
    return OutfitPlan(
      id: json['id'] as int,
      date: DateTime.parse(json['date']),
      items: (json['items'] as List)
          .map((item) => WardrobeItem.fromJson(item))
          .toList(),
      notes: json['notes'] as String?,
      weatherCondition: json['weather_condition'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  /// Convert OutfitPlan to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
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