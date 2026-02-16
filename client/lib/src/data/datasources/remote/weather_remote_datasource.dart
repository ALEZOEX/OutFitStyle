import 'dart:convert';
import '../../remote/api_client.dart';

abstract class IWeatherRemoteDataSource {
  Future<Map<String, dynamic>> getCurrentWeather(double latitude, double longitude);
  Future<Map<String, dynamic>> getWeatherForecast(double latitude, double longitude);
}

class WeatherRemoteDataSource implements IWeatherRemoteDataSource {
  final ApiClient _apiClient;

  WeatherRemoteDataSource(this._apiClient);

  @override
  Future<Map<String, dynamic>> getCurrentWeather(double latitude, double longitude) async {
    final response = await _apiClient.get(
      '/weather/current',
      params: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw WeatherRemoteException('Не удалось получить текущую погоду');
  }

  @override
  Future<Map<String, dynamic>> getWeatherForecast(double latitude, double longitude) async {
    final response = await _apiClient.get(
      '/weather/forecast',
      params: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw WeatherRemoteException('Не удалось получить прогноз погоды');
  }
}

/// Исключение remote datasource погоды
class WeatherRemoteException implements Exception {
  final String message;
  const WeatherRemoteException(this.message);

  @override
  String toString() => 'WeatherRemoteException: $message';
}