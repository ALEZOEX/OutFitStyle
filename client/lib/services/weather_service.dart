import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  final String apiKey;
  final String baseUrl;
  final int timeout;

  WeatherService({
    required this.apiKey,
    required this.baseUrl,
    this.timeout = 30,
  });

  Future<Map<String, dynamic>> getWeatherForecast(String city) async {
    try {
      final url = Uri.https(baseUrl, '/api/weather',
          {'q': city, 'appid': apiKey, 'units': 'metric', 'lang': 'ru'});

      final response = await http.get(url).timeout(
            Duration(seconds: timeout),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'],
          'condition': data['weather'][0]['description'],
          'humidity': data['main']['humidity'],
          'wind_speed': data['wind']['speed'],
        };
      } else {
        throw Exception('Failed to load weather forecast');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<WeatherData> getWeather(String city) async {
    try {
      final url = Uri.https(baseUrl, '/api/weather',
          {'q': city, 'appid': apiKey, 'units': 'metric', 'lang': 'ru'});

      final response = await http.get(url).timeout(
            Duration(seconds: timeout),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Example usage:
// final weatherService = WeatherService(
//   apiKey: AppConfig.weatherApiKey,
//   baseUrl: AppConfig.weatherBaseUrl,
// );
