import 'package:logger/logger.dart';

import '../repositories/i_weather_repository.dart';
import '../entities/weather_data.dart';

abstract class GetWeatherUsecase {
  Future<WeatherData?> execute(double latitude, double longitude);
}

class GetWeatherUsecaseImpl implements GetWeatherUsecase {
  final IWeatherRepository _repository;
  final Logger _logger;

  GetWeatherUsecaseImpl(this._repository, this._logger);

  @override
  Future<WeatherData?> execute(double latitude, double longitude) async {
    try {
      _logger.d('Executing GetWeatherUsecase for coordinates: $latitude, $longitude');
      
      // First try to get from cache
      var weather = await _repository.getCurrentWeather(latitude, longitude);
      
      if (weather != null) {
        _logger.d('GetWeatherUsecase completed successfully');
      } else {
        _logger.w('GetWeatherUsecase returned null');
      }
      
      return weather;
    } catch (e) {
      _logger.e('Error in GetWeatherUsecase: $e');
      rethrow;
    }
  }
}

abstract class GetWeatherForecastUsecase {
  Future<List<WeatherData>?> execute(double latitude, double longitude);
}

class GetWeatherForecastUsecaseImpl implements GetWeatherForecastUsecase {
  final IWeatherRepository _repository;
  final Logger _logger;

  GetWeatherForecastUsecaseImpl(this._repository, this._logger);

  @override
  Future<List<WeatherData>?> execute(double latitude, double longitude) async {
    try {
      _logger.d('Executing GetWeatherForecastUsecase for coordinates: $latitude, $longitude');
      
      final forecast = await _repository.getForecast(latitude, longitude);
      
      _logger.d('GetWeatherForecastUsecase completed with ${forecast.length} items');
      return forecast;
    } catch (e) {
      _logger.e('Error in GetWeatherForecastUsecase: $e');
      rethrow;
    }
  }
}

abstract class GetHistoricalWeatherUsecase {
  Future<List<WeatherData>?> execute(double latitude, double longitude, DateTime startDate, DateTime endDate);
}

class GetHistoricalWeatherUsecaseImpl implements GetHistoricalWeatherUsecase {
  final IWeatherRepository _repository;
  final Logger _logger;

  GetHistoricalWeatherUsecaseImpl(this._repository, this._logger);

  @override
  Future<List<WeatherData>?> execute(double latitude, double longitude, DateTime startDate, DateTime endDate) async {
    try {
      _logger.d('Executing GetHistoricalWeatherUsecase for coordinates: $latitude, $longitude '
                'from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      
      // For now, just return empty list as the repository doesn't have this method
      _logger.d('GetHistoricalWeatherUsecase completed with 0 items');
      return [];
    } catch (e) {
      _logger.e('Error in GetHistoricalWeatherUsecase: $e');
      rethrow;
    }
  }
}