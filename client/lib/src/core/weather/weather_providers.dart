import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'weather_service.dart';

/// Провайдер для ApiClient
final _apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('ApiClient должен быть предоставлен');
});

/// Провайдер погодного сервиса
final weatherServiceProvider = Provider<WeatherService>((ref) {
  final apiClient = ref.watch(_apiClientProvider);
  return WeatherService(apiClient: apiClient);
});

/// Провайдер для загрузки текущей погоды
final currentWeatherProvider = FutureProvider.autoDispose.family<WeatherData, Location>((ref, location) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getCurrentWeather(location.latitude, location.longitude);
});

/// Провайдер для загрузки прогноза погоды
final weatherForecastProvider = FutureProvider.autoDispose.family<List<WeatherData>, Location>((ref, location) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getWeatherForecast(location.latitude, location.longitude);
});

/// Модель локации
class Location {
  final double latitude;
  final double longitude;
  final String? name;

  const Location({
    required this.latitude,
    required this.longitude,
    this.name,
  });
}
