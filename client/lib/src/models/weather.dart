/// Модель данных погоды для тестов
/// 
/// Используется в weather_service_test.dart для тестирования WeatherService
class Weather {
  final double temperature;
  final double? feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;

  const Weather({
    required this.temperature,
    this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          feelsLike == other.feelsLike &&
          humidity == other.humidity &&
          windSpeed == other.windSpeed &&
          description == other.description &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(
        temperature,
        feelsLike,
        humidity,
        windSpeed,
        description,
        icon,
      );

  @override
  String toString() {
    return 'Weather(temperature: $temperature, feelsLike: $feelsLike, '
        'humidity: $humidity, windSpeed: $windSpeed, '
        'description: $description, icon: $icon)';
  }
}

/// Модель прогноза погоды
class WeatherForecast {
  final String location;
  final List<Weather> forecasts;

  const WeatherForecast({
    required this.location,
    required this.forecasts,
  });
}
