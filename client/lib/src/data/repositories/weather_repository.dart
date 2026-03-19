import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import '../../domain/repositories/i_weather_repository.dart';

/// Репозиторий погоды
class WeatherRepository implements IWeatherRepository {
  final ApiClient apiClient;
  final Future<SharedPreferences> sharedPreferences;

  WeatherRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future<Map<String, dynamic>> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    final response = await apiClient.get(
      '/weather/current',
      params: {'lat': latitude.toString(), 'lon': longitude.toString()},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.data) as Map<String, dynamic>;
    }
    throw WeatherException('Не удалось получить текущую погоду');
  }

  @override
  Future<Map<String, dynamic>> getWeatherForecast(
    double latitude,
    double longitude,
  ) async {
    final response = await apiClient.get(
      '/weather/forecast',
      params: {'lat': latitude.toString(), 'lon': longitude.toString()},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.data) as Map<String, dynamic>;
    }
    throw WeatherException('Не удалось получить прогноз погоды');
  }
}

/// Исключение репозитория погоды
class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}
