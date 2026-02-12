abstract class IWeatherRepository {
  Future<Map<String, dynamic>> getCurrentWeather(double latitude, double longitude);
  Future<Map<String, dynamic>> getWeatherForecast(double latitude, double longitude);
}