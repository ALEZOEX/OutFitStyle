import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum OutfitWeather {
  sunny('sunny'),
  cloudy('cloudy'),
  rainy('rainy'),
  snowy('snowy'),
  windy('windy'),
  hot('hot'),
  cold('cold'),
  mild('mild');

  const OutfitWeather(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case OutfitWeather.sunny:
        return 'Солнечно';
      case OutfitWeather.cloudy:
        return 'Облачно';
      case OutfitWeather.rainy:
        return 'Дождливо';
      case OutfitWeather.snowy:
        return 'Снежно';
      case OutfitWeather.windy:
        return 'Ветрено';
      case OutfitWeather.hot:
        return 'Жарко';
      case OutfitWeather.cold:
        return 'Холодно';
      case OutfitWeather.mild:
        return 'Умеренно';
    }
  }

  static OutfitWeather fromValue(String value) {
    return OutfitWeather.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OutfitWeather.mild,
    );
  }
}
