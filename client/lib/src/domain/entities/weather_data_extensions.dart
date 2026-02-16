import 'dart:math' as math;
import 'weather_data.dart';

/// Extension methods for WeatherData business logic
extension WeatherDataExtensions on WeatherData {
  bool get isCold => (temperature ?? 0) < 10.0;
  bool get isWarm => (temperature ?? 0) >= 10.0 && (temperature ?? 0) < 25.0;
  bool get isHot => (temperature ?? 0) >= 25.0;

  bool get isRainy => (condition?.toLowerCase().contains('rain') ?? false) ||
                    (description?.toLowerCase().contains('rain') ?? false);

  bool get isSnowy => (condition?.toLowerCase().contains('snow') ?? false) ||
                    (description?.toLowerCase().contains('snow') ?? false);

  bool get isWindy => (windSpeed ?? 0) > 10.0; // больше 10 м/с - ветрено

  bool get isHumid => (humidity ?? 0) > 70; // выше 70% - влажно

  double get perceivedTemperature {
    final temp = temperature ?? 0.0;
    final wind = windSpeed ?? 0.0;
    final hum = humidity ?? 0.0;

    if (temp == 0.0 && wind == 0.0) return feelsLike ?? 0.0;

    // Упрощенный расчет ощущаемой температуры
    if (wind > 4.8 && temp < 10) {
      // Wind chill factor
      return 13.12 + 0.6215 * temp - 11.37 * math.pow(wind * 3.6, 0.16) + 0.3965 * temp * math.pow(wind * 3.6, 0.16);
    } else if (hum > 50 && temp > 27) {
      // Heat index
      final t = temp;
      final rh = hum;
      return -8.78469475556 + 1.61139411 * t + 2.33854883889 * rh - 0.14611605 * t * rh - 0.012308094 * t * t - 0.0164248277778 * rh * rh + 0.002211732 * t * t * rh + 0.00072546 * t * rh * rh - 0.000003582 * t * t * rh * rh;
    }
    return feelsLike ?? temp;
  }

  String get clothingRecommendation {
    if (isCold) {
      return 'Warm jacket, sweater, scarf';
    } else if (isWarm) {
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

  DateTime get timestamp => DateTime.now();
}