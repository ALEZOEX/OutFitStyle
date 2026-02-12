import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ClothingSeason {
  spring('spring'),
  summer('summer'),
  autumn('autumn'),
  winter('winter'),
  allSeason('all_season');

  const ClothingSeason(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ClothingSeason.spring:
        return 'Весна';
      case ClothingSeason.summer:
        return 'Лето';
      case ClothingSeason.autumn:
        return 'Осень';
      case ClothingSeason.winter:
        return 'Зима';
      case ClothingSeason.allSeason:
        return 'Все сезоны';
    }
  }

  static ClothingSeason fromValue(String value) {
    return ClothingSeason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClothingSeason.allSeason,
    );
  }
}
