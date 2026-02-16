import 'package:geocoding/geocoding.dart';

import '../entities/weather_data.dart';
import '../../data/datasources/remote/weather_remote_datasource.dart';

/// Repository for managing weather data operations
abstract class WeatherRepository {
  /// Get current weather and forecast for a specific location
  Future<WeatherData> getWeatherByLocation(double latitude, double longitude);

  /// Get current weather and forecast for a specific city
  Future<WeatherData> getWeatherByCity(String city);
}

/// Implementation of WeatherRepository using remote data source
class WeatherDataRepository implements WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;

  WeatherDataRepository(this._remoteDataSource);

  @override
  Future<WeatherData> getWeatherByLocation(double latitude, double longitude) async {
    final data = await _remoteDataSource.getCurrentWeather(latitude, longitude);
    return WeatherData.fromJson(data);
  }

  @override
  Future<WeatherData> getWeatherByCity(String city) async {
    // Используем geocoding для получения координат из названия города
    final locations = await locationFromAddress(city);

    if (locations.isEmpty) {
      throw WeatherGeocodingException('Город не найден: $city');
    }

    final location = locations.first;
    return getWeatherByLocation(location.latitude, location.longitude);
  }
}

/// Исключение при ошибке геосодинга
class WeatherGeocodingException implements Exception {
  final String message;
  const WeatherGeocodingException(this.message);

  @override
  String toString() => 'WeatherGeocodingException: $message';
}
