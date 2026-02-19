import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_data.dart';
import '../../core/weather/weather_service.dart';
import '../../core/api/api_client.dart';

/// Провайдер для получения погоды по координатам
///
/// Пример использования:
/// ```dart
/// final weather = ref.watch(weatherProvider((lat: 55.75, lon: 37.61)));
/// ```
final weatherProvider = FutureProvider.family.autoDispose<WeatherData, ({double lat, double lon})>((ref, location) async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final apiClient = ApiClient.internal(dio);
  final weatherService = WeatherService(apiClient: apiClient);

  return await weatherService.getCurrentWeather(location.lat, location.lon);
});

/// Провайдер для получения прогноза погоды
final weatherForecastProvider = FutureProvider.family.autoDispose<List<WeatherData>, ({double lat, double lon, int days})>((ref, config) async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final apiClient = ApiClient.internal(dio);
  final weatherService = WeatherService(apiClient: apiClient);

  return await weatherService.getWeatherForecast(
    config.lat,
    config.lon,
    days: config.days,
  );
});
