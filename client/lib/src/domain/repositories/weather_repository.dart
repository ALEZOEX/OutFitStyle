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
    // TODO: Implement geocoding to get coordinates from city name
    throw UnimplementedError();
  }
}
