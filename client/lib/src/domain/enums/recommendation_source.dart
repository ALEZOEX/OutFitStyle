import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum RecommendationSource {
  weather('weather'),
  occasion('occasion'),
  activity('activity'),
  trending('trending'),
  personalized('personalized'),
  collaborative('collaborative'),
  contentBased('content_based'),
  manual('manual'),
  system('system');

  const RecommendationSource(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case RecommendationSource.weather:
        return 'Погода';
      case RecommendationSource.occasion:
        return 'Повод';
      case RecommendationSource.activity:
        return 'Активность';
      case RecommendationSource.trending:
        return 'В тренде';
      case RecommendationSource.personalized:
        return 'Персонализированные';
      case RecommendationSource.collaborative:
        return 'Коллаборативная фильтрация';
      case RecommendationSource.contentBased:
        return 'На основе контента';
      case RecommendationSource.manual:
        return 'Ручной ввод';
      case RecommendationSource.system:
        return 'Системные';
    }
  }

  static RecommendationSource fromValue(String? value) {
    if (value == null) return RecommendationSource.values.first;
    return RecommendationSource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecommendationSource.values.first,
    );
  }
}
