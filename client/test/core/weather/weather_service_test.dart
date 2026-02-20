import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outfitstyle_client/src/core/weather/weather_service.dart';
import 'package:outfitstyle_client/src/core/api/api_client.dart';
import 'package:outfitstyle_client/src/models/weather.dart';

// Mock для ApiClient
class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('WeatherService Tests', () {
    late WeatherService weatherService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      weatherService = WeatherService(apiClient: mockApiClient);
    });

    test('WeatherService is initialized', () {
      expect(weatherService, isNotNull);
    });

    test('WeatherModel can be created', () {
      const weather = Weather(
        temperature: 20.5,
        feelsLike: 19.0,
        humidity: 65,
        windSpeed: 3.2,
        description: 'Clear',
        icon: '01d',
      );

      expect(weather.temperature, 20.5);
      expect(weather.feelsLike, 19.0);
      expect(weather.humidity, 65);
      expect(weather.windSpeed, 3.2);
      expect(weather.description, 'Clear');
      expect(weather.icon, '01d');
    });

    test('WeatherModel handles negative temperature', () {
      const weather = Weather(
        temperature: -10.5,
        feelsLike: -15.0,
        humidity: 80,
        windSpeed: 5.0,
        description: 'Snow',
        icon: '13d',
      );

      expect(weather.temperature, -10.5);
      expect(weather.feelsLike, -15.0);
    });

    test('WeatherModel equality', () {
      const weather1 = Weather(
        temperature: 20.0,
        feelsLike: 19.0,
        humidity: 60,
        windSpeed: 3.0,
        description: 'Clear',
        icon: '01d',
      );

      const weather2 = Weather(
        temperature: 20.0,
        feelsLike: 19.0,
        humidity: 60,
        windSpeed: 3.0,
        description: 'Clear',
        icon: '01d',
      );

      const weather3 = Weather(
        temperature: 25.0,
        feelsLike: 24.0,
        humidity: 60,
        windSpeed: 3.0,
        description: 'Clear',
        icon: '01d',
      );

      expect(weather1, equals(weather2));
      expect(weather1, isNot(equals(weather3)));
    });

    test('WeatherModel toString', () {
      const weather = Weather(
        temperature: 20.5,
        feelsLike: 19.0,
        humidity: 65,
        windSpeed: 3.2,
        description: 'Clear',
        icon: '01d',
      );

      final str = weather.toString();
      expect(str, contains('20.5'));
      expect(str, contains('Clear'));
    });

    test('Weather conditions classification', () {
      const clear = Weather(
        temperature: 20.0,
        feelsLike: 19.0,
        humidity: 60,
        windSpeed: 3.0,
        description: 'Clear',
        icon: '01d',
      );

      const rain = Weather(
        temperature: 15.0,
        feelsLike: 14.0,
        humidity: 80,
        windSpeed: 5.0,
        description: 'Rain',
        icon: '10d',
      );

      const snow = Weather(
        temperature: -5.0,
        feelsLike: -10.0,
        humidity: 70,
        windSpeed: 4.0,
        description: 'Snow',
        icon: '13d',
      );

      expect(clear.description, 'Clear');
      expect(rain.description, 'Rain');
      expect(snow.description, 'Snow');
    });

    test('Weather comfort level calculation', () {
      // Комфортная погода
      const comfortable = Weather(
        temperature: 22.0,
        feelsLike: 22.0,
        humidity: 50,
        windSpeed: 2.0,
        description: 'Clear',
        icon: '01d',
      );

      // Холодная погода
      const cold = Weather(
        temperature: 5.0,
        feelsLike: 2.0,
        humidity: 70,
        windSpeed: 5.0,
        description: 'Cloudy',
        icon: '04d',
      );

      // Жаркая погода
      const hot = Weather(
        temperature: 35.0,
        feelsLike: 38.0,
        humidity: 40,
        windSpeed: 1.0,
        description: 'Clear',
        icon: '01d',
      );

      expect(comfortable.temperature, greaterThan(cold.temperature));
      expect(hot.temperature, greaterThan(comfortable.temperature));
    });
  });

  group('Weather Forecast Tests', () {
    test('WeatherForecast can be created', () {
      final forecast = WeatherForecast(
        location: 'Moscow',
        forecasts: [
          const Weather(
            temperature: 20.0,
            feelsLike: 19.0,
            humidity: 60,
            windSpeed: 3.0,
            description: 'Clear',
            icon: '01d',
          ),
          const Weather(
            temperature: 18.0,
            feelsLike: 17.0,
            humidity: 65,
            windSpeed: 3.5,
            description: 'Cloudy',
            icon: '04d',
          ),
        ],
      );

      expect(forecast.location, 'Moscow');
      expect(forecast.forecasts.length, 2);
    });

    test('WeatherForecast empty list', () {
      final forecast = WeatherForecast(
        location: 'Unknown',
        forecasts: [],
      );

      expect(forecast.location, 'Unknown');
      expect(forecast.forecasts.isEmpty, true);
    });
  });
}
