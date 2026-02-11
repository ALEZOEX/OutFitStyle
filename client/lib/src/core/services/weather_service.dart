import 'package:dio/dio.dart';
import 'package:outfitstyle_client/src/domain/entities/weather_data.dart';

/// Service for interacting with weather APIs
/// Note: This service follows the repository pattern and should typically be used through the WeatherRepository
class WeatherService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;

  WeatherService({
    required Dio dio,
    required String apiKey,
    String baseUrl = 'https://api.openweathermap.org/data/2.5',
  })  : _dio = dio,
        _apiKey = apiKey,
        _baseUrl = baseUrl;

  /// Fetch current weather data for a location (used internally by repository)
  @Deprecated('Use WeatherRepository instead')
  Future<WeatherData> getWeatherByLocation(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      final data = response.data;

      return WeatherData(
        temperature: (data['main']['temp'] as num).toDouble(),
        feelsLike: (data['main']['feels_like'] as num).toDouble(),
        humidity: data['main']['humidity'],
        windSpeed: (data['wind']['speed'] as num).toDouble(),
        condition: _getWeatherCondition(data['weather'][0]['main']),
        iconCode: data['weather'][0]['icon'],
        timestamp: DateTime.now(),
        latitude: lat,
        longitude: lon,
        locationName: data['name'],
        hourlyForecast: [], // Will be populated by repository with forecast API
        dailyForecast: [], // Will be populated by repository with forecast API
      );
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  /// Fetch weather by city name (used internally by repository)
  @Deprecated('Use WeatherRepository instead')
  Future<WeatherData> getWeatherByCity(String cityName) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'q': cityName,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      final data = response.data;
      final lat = data['coord']['lat'];
      final lon = data['coord']['lon'];

      return await getWeatherByLocation(lat, lon);
    } catch (e) {
      throw Exception('Failed to fetch weather data for city: $e');
    }
  }

  /// Get weather condition string from API code
  String _getWeatherCondition(String mainWeather) {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return 'Clear';
      case 'clouds':
        return 'Cloudy';
      case 'rain':
        return 'Rainy';
      case 'drizzle':
        return 'Drizzle';
      case 'thunderstorm':
        return 'Thunderstorm';
      case 'snow':
        return 'Snow';
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
      case 'dust':
      case 'sand':
      case 'ash':
        return 'Foggy';
      case 'squall':
      case 'tornado':
        return 'Stormy';
      default:
        return 'Unknown';
    }
  }
}
