import '../repositories/i_weather_repository.dart';
import '../entities/weather_data.dart';

abstract class GetWeatherUsecase {
  Future<WeatherData?> execute(double latitude, double longitude);
}

class GetWeatherUsecaseImpl implements GetWeatherUsecase {
  final IWeatherRepository _repository;

  GetWeatherUsecaseImpl(this._repository);

  @override
  Future<WeatherData?> execute(double latitude, double longitude) async {
    final weatherData = await _repository.getCurrentWeather(
      latitude,
      longitude,
    );
    return WeatherData.fromJson(weatherData);
  }
}

abstract class GetWeatherForecastUsecase {
  Future<List<WeatherData>?> execute(double latitude, double longitude);
}

class GetWeatherForecastUsecaseImpl implements GetWeatherForecastUsecase {
  final IWeatherRepository _repository;

  GetWeatherForecastUsecaseImpl(this._repository);

  @override
  Future<List<WeatherData>?> execute(double latitude, double longitude) async {
    try {
      final forecastData = await _repository.getWeatherForecast(
        latitude,
        longitude,
      );
      final forecast = [WeatherData.fromJson(forecastData)];
      return forecast;
    } catch (e) {
      rethrow;
    }
  }
}

abstract class GetHistoricalWeatherUsecase {
  Future<List<WeatherData>?> execute(
    double latitude,
    double longitude,
    DateTime startDate,
    DateTime endDate,
  );
}

class GetHistoricalWeatherUsecaseImpl implements GetHistoricalWeatherUsecase {
  GetHistoricalWeatherUsecaseImpl();

  @override
  Future<List<WeatherData>?> execute(
    double latitude,
    double longitude,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // For now, just return empty list as the repository doesn't have this method
    return [];
  }
}
