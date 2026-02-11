// lib/src/domain/enums/recommendation_type.dart
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum RecommendationType {
  outfit('outfit'),
  clothing('clothing'),
  style('style'),
  weather('weather'),
  occasion('occasion'),
  trending('trending'),
  personalized('personalized');

  const RecommendationType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case RecommendationType.outfit:
        return 'Образ';
      case RecommendationType.clothing:
        return 'Одежда';
      case RecommendationType.style:
        return 'Стиль';
      case RecommendationType.weather:
        return 'Погода';
      case RecommendationType.occasion:
        return 'Повод';
      case RecommendationType.trending:
        return 'В тренде';
      case RecommendationType.personalized:
        return 'Персонализированные';
    }
  }

  static RecommendationType fromValue(String? value) {
    if (value == null) return RecommendationType.values.first;
    return RecommendationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecommendationType.values.first,
    );
  }
}
