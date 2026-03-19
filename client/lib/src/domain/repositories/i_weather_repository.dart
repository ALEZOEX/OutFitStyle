/// Интерфейс репозитория погоды
abstract class IWeatherRepository {
  /// Получить текущую погоду
  Future<Map<String, dynamic>> getCurrentWeather(
    double latitude,
    double longitude,
  );

  /// Получить прогноз погоды
  Future<Map<String, dynamic>> getWeatherForecast(
    double latitude,
    double longitude,
  );
}
