import '../entities/weather_data.dart';

abstract class IWeatherRepository {
  Future<WeatherData> getCurrentWeather(double latitude, double longitude);
  Future<WeatherData> getWeatherByCity(String city);
  Future<List<WeatherData>> getWeatherForecast(double latitude, double longitude, {int days = 7});
  Future<List<WeatherData>> getHistoricalWeather(double latitude, double longitude, {DateTime? startDate, DateTime? endDate});
  Future<WeatherData> getWeatherForOutfitSelection(double latitude, double longitude);
  Future<Map<String, dynamic>> getWeatherAlerts(double latitude, double longitude);
  Future<void> cacheWeatherData(WeatherData weatherData);
  Future<WeatherData?> getCachedWeatherData(double latitude, double longitude);
  Future<void> updateWeatherPreferences(Map<String, dynamic> preferences);
  Future<Map<String, dynamic>> getWeatherPreferences();
}