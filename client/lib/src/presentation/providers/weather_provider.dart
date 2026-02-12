import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_data.dart';

// Провайдер для данных о погоде
final weatherProvider = StateProvider<WeatherData?>((ref) => null);

// Алиас для совместимости
final currentWeatherProvider = weatherProvider;
