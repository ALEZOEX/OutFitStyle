/// Сущность погоды
class WeatherEntity {
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;

  WeatherEntity({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  /// Создает экземпляр [WeatherEntity] из JSON-объекта
  factory WeatherEntity.fromJson(Map<String, dynamic> json) {
    return WeatherEntity(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      humidity: json['humidity']?.toDouble() ?? 0.0,
      windSpeed: json['wind_speed']?.toDouble() ?? 0.0,
    );
  }

  /// Преобразует экземпляр [WeatherEntity] в JSON-объект
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'wind_speed': windSpeed,
    };
  }
}