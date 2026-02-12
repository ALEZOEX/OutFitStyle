import '../entities/weather_data.dart';
import '../../data/datasources/weather_remote_datasource.dart';

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
  Future<WeatherData> getWeatherByLocation(double latitude, double longitude) {
    return _remoteDataSource.getWeatherByLocation(latitude, longitude);
  }

  @override
  Future<WeatherData> getWeatherByCity(String city) {
    return _remoteDataSource.getWeatherByCity(city);
  }
}
