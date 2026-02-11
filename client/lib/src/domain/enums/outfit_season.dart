import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OutfitSeason {
  spring('spring'),
  summer('summer'),
  autumn('autumn'),
  winter('winter'),
  allSeason('all_season');

  const OutfitSeason(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case OutfitSeason.spring:
        return 'Весна';
      case OutfitSeason.summer:
        return 'Лето';
      case OutfitSeason.autumn:
        return 'Осень';
      case OutfitSeason.winter:
        return 'Зима';
      case OutfitSeason.allSeason:
        return 'Все сезоны';
    }
  }

  static OutfitSeason fromValue(String value) {
    return OutfitSeason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OutfitSeason.allSeason,
    );
  }
}
