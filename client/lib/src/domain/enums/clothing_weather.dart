import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ClothingWeather {
  sunny('sunny'),
  cloudy('cloudy'),
  rainy('rainy'),
  snowy('snowy'),
  windy('windy'),
  hot('hot'),
  cold('cold'),
  mild('mild');

  const ClothingWeather(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case ClothingWeather.sunny:
        return 'Солнечно';
      case ClothingWeather.cloudy:
        return 'Облачно';
      case ClothingWeather.rainy:
        return 'Дождливо';
      case ClothingWeather.snowy:
        return 'Снежно';
      case ClothingWeather.windy:
        return 'Ветрено';
      case ClothingWeather.hot:
        return 'Жарко';
      case ClothingWeather.cold:
        return 'Холодно';
      case ClothingWeather.mild:
        return 'Умеренно';
    }
  }

  static ClothingWeather fromValue(String value) {
    return ClothingWeather.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClothingWeather.mild,
    );
  }
}
