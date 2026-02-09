import 'dart:math' as math;
import 'package:equatable/equatable.dart';

// Доменная сущность для погодных данных
class WeatherData extends Equatable {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String weatherCondition;
  final String description;
  final double pressure;
  final double visibility;
  final double uvIndex;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double minTemperature;
  final double maxTemperature;
  final String locationName;

  const WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCondition,
    required this.description,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.minTemperature,
    required this.maxTemperature,
    required this.locationName,
  });

  @override
  List<Object?> get props => [
        temperature,
        feelsLike,
        humidity,
        windSpeed,
        weatherCondition,
        description,
        pressure,
        visibility,
        uvIndex,
        timestamp,
        latitude,
        longitude,
        minTemperature,
        maxTemperature,
        locationName,
      ];

  WeatherData copyWith({
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    String? weatherCondition,
    String? description,
    double? pressure,
    double? visibility,
    double? uvIndex,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? minTemperature,
    double? maxTemperature,
    String? locationName,
  }) {
    return WeatherData(
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      description: description ?? this.description,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      locationName: locationName ?? this.locationName,
    );
  }

  // Методы бизнес-логики
  bool isCold() => temperature < 10.0;
  bool isWarm() => temperature >= 10.0 && temperature < 25.0;
  bool isHot() => temperature >= 25.0;

  bool isRainy() => weatherCondition.toLowerCase().contains('rain') || 
                  description.toLowerCase().contains('rain');
  
  bool isSnowy() => weatherCondition.toLowerCase().contains('snow') || 
                   description.toLowerCase().contains('snow');
  
  bool isWindy() => windSpeed > 10.0; // больше 10 м/с - ветрено
  
  bool isHumid() => humidity > 70; // выше 70% - влажно
  
  double get perceivedTemperature {
    // Упрощенный расчет ощущаемой температуры
    if (windSpeed > 4.8 && temperature < 10) {
      // Wind chill factor
      return 13.12 + 0.6215 * temperature - 11.37 * math.pow(windSpeed * 3.6, 0.16) + 0.3965 * temperature * math.pow(windSpeed * 3.6, 0.16);
    } else if (humidity > 50 && temperature > 27) {
      // Heat index
      final t = temperature;
      final rh = humidity;
      return -8.78469475556 + 1.61139411 * t + 2.33854883889 * rh - 0.14611605 * t * rh - 0.012308094 * t * t - 0.0164248277778 * rh * rh + 0.002211732 * t * t * rh + 0.00072546 * t * rh * rh - 0.000003582 * t * t * rh * rh;
    }
    return feelsLike;
  }

  String get clothingRecommendation {
    if (isCold()) {
      return 'Warm jacket, sweater, scarf';
    } else if (isWarm()) {
      return 'Light jacket or sweater';
    } else {
      return 'T-shirt, shorts';
    }
  }

  Duration get timeSinceUpdate {
    return DateTime.now().difference(timestamp);
  }

  bool get isStale {
    // Считаем данные устаревшими после 30 минут
    return timeSinceUpdate.inMinutes > 30;
  }
}