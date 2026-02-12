import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ClothingCategory {
  tops('tops'),
  bottoms('bottoms'),
  dresses('dresses'),
  outerwear('outerwear'),
  shoes('shoes'),
  accessories('accessories'),
  bags('bags'),
  sportswear('sportswear');

  const ClothingCategory(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ClothingCategory.tops:
        return 'Верх';
      case ClothingCategory.bottoms:
        return 'Низ';
      case ClothingCategory.dresses:
        return 'Платья';
      case ClothingCategory.outerwear:
        return 'Верхняя одежда';
      case ClothingCategory.shoes:
        return 'Обувь';
      case ClothingCategory.accessories:
        return 'Аксессуары';
      case ClothingCategory.bags:
        return 'Сумки';
      case ClothingCategory.sportswear:
        return 'Спортивная одежда';
    }
  }

  static ClothingCategory fromValue(String value) {
    return ClothingCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClothingCategory.tops,
    );
  }
}
