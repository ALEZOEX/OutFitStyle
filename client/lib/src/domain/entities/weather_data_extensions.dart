import 'dart:math' as math;
import 'weather_data.dart';

/// Extension methods for WeatherData business logic
extension WeatherDataExtensions on WeatherData {
  bool get isCold => temperature != null && temperature! < 10.0;
  bool get isWarm => temperature != null && temperature! >= 10.0 && temperature! < 25.0;
  bool get isHot => temperature != null && temperature! >= 25.0;

  bool get isRainy => condition?.toLowerCase().contains('rain') == true || 
                    description?.toLowerCase().contains('rain') == true;

  bool get isSnowy => condition?.toLowerCase().contains('snow') == true || 
                    description?.toLowerCase().contains('snow') == true;

  bool get isWindy => windSpeed != null && windSpeed! > 10.0; // больше 10 м/с - ветрено

  bool get isHumid => humidity != null && humidity! > 70; // выше 70% - влажно

  double get perceivedTemperature {
    if (temperature == null || windSpeed == null) return feelsLike ?? 0.0;
    
    // Упрощенный расчет ощущаемой температуры
    if (windSpeed! > 4.8 && temperature! < 10) {
      // Wind chill factor
      return 13.12 + 0.6215 * temperature! - 11.37 * math.pow(windSpeed! * 3.6, 0.16) + 0.3965 * temperature! * math.pow(windSpeed! * 3.6, 0.16);
    } else if (humidity != null && humidity! > 50 && temperature! > 27) {
      // Heat index
      final t = temperature!;
      final rh = humidity!;
      return -8.78469475556 + 1.61139411 * t + 2.33854883889 * rh - 0.14611605 * t * rh - 0.012308094 * t * t - 0.0164248277778 * rh * rh + 0.002211732 * t * t * rh + 0.00072546 * t * rh * rh - 0.000003582 * t * t * rh * rh;
    }
    return feelsLike ?? temperature!;
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
    return DateTime.now().difference(timestamp ?? DateTime.now());
  }

  bool get isStale {
    // Считаем данные устаревшими после 30 минут
    return timeSinceUpdate.inMinutes > 30;
  }
  
  DateTime get timestamp => DateTime.now();
}