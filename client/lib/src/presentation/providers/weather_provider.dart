import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/weather_data.dart';
import '../../core/weather/weather_service.dart';
import '../../core/api/api_client.dart';

final _dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});

final _weatherServiceProvider = Provider<WeatherService>((ref) {
  final dio = ref.watch(_dioProvider);
  final apiClient = ApiClient.internal(dio);
  return WeatherService(apiClient: apiClient);
});

final weatherProvider = FutureProvider.family
    .autoDispose<WeatherData, ({double lat, double lon})>((
      ref,
      location,
    ) async {
      final weatherService = ref.watch(_weatherServiceProvider);
      return await weatherService.getCurrentWeather(location.lat, location.lon);
    });

final weatherForecastProvider = FutureProvider.family
    .autoDispose<List<WeatherData>, ({double lat, double lon, int days})>((
      ref,
      config,
    ) async {
      final weatherService = ref.watch(_weatherServiceProvider);
      return await weatherService.getWeatherForecast(
        config.lat,
        config.lon,
        days: config.days,
      );
    });
