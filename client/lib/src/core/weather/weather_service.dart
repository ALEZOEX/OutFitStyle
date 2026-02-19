import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../../domain/entities/weather_data.dart';

/// Сервис для получения данных о погоде
///
/// Использует Open-Meteo API (бесплатный, не требует API ключа)
/// или OpenWeatherMap API (требует API ключ)
///
/// Кэширует данные на 30 минут для уменьшения количества запросов
class WeatherService {
  final ApiClient _apiClient;
  
  // Open-Meteo API (бесплатный)
  static const String _openMeteoBaseUrl = 'https://api.open-meteo.com/v1';
  
  // Кэш погоды
  final Map<String, _WeatherCacheEntry> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 30);

  WeatherService({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Получить текущую погоду по координатам
  /// 
  /// [latitude] - широта
  /// [longitude] - долгота
  /// 
  /// Возвращает [WeatherData] с текущими погодными условиями
  Future<WeatherData> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    final cacheKey = '$latitude,$longitude';
    
    // Проверяем кэш
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }

    try {
      // Используем Open-Meteo API
      final response = await _apiClient.raw.get(
        '$_openMeteoBaseUrl/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current_weather': true,
          'hourly': 'temperature_2m,relative_humidity_2m,weather_code',
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final weather = _parseOpenMeteoResponse(data);
        
        // Сохраняем в кэш
        _cache[cacheKey] = _WeatherCacheEntry(
          data: weather,
          expiresAt: DateTime.now().add(_cacheDuration),
        );
        
        return weather;
      } else {
        throw WeatherException('Ошибка получения погоды: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Ошибка получения погоды: $e');
    }
  }

  /// Получить прогноз погоды на несколько дней
  /// 
  /// [latitude] - широта
  /// [longitude] - долгота
  /// [days] - количество дней прогноза (1-14)
  /// 
  /// Возвращает список [WeatherData] для каждого дня
  Future<List<WeatherData>> getWeatherForecast(
    double latitude,
    double longitude, {
    int days = 7,
  }) async {
    try {
      final response = await _apiClient.raw.get(
        '$_openMeteoBaseUrl/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
          'timezone': 'auto',
          'forecast_days': days.clamp(1, 14),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return _parseOpenMeteoForecast(data);
      } else {
        throw WeatherException('Ошибка получения прогноза: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Ошибка получения прогноза: $e');
    }
  }

  /// Получить название погодного условия по коду WMO
  String _getWeatherCondition(int code) {
    // WMO Weather interpretation codes (WW)
    if (code == 0) return 'clear';
    if (code >= 1 && code <= 3) return 'partly_cloudy';
    if (code >= 45 && code <= 48) return 'foggy';
    if (code >= 51 && code <= 67) return 'rain';
    if (code >= 71 && code <= 77) return 'snow';
    if (code >= 80 && code <= 82) return 'rain';
    if (code >= 85 && code <= 86) return 'snow';
    if (code >= 95 && code <= 99) return 'thunderstorm';
    return 'unknown';
  }

  WeatherData _parseOpenMeteoResponse(Map<String, dynamic> data) {
    final current = data['current_weather'] as Map<String, dynamic>;

    return WeatherData(
      temperature: (current['temperature'] as num).toDouble(),
      feelsLike: (current['temperature'] as num).toDouble(), // Open-Meteo не предоставляет feels_like
      condition: _getWeatherCondition(current['weathercode'] as int),
      humidity: 50, // Open-Meteo требует отдельного запроса
      windSpeed: (current['windspeed'] as num).toDouble(),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
    );
  }

  List<WeatherData> _parseOpenMeteoForecast(Map<String, dynamic> data) {
    final daily = data['daily'] as Map<String, dynamic>;
    final times = daily['time'] as List;
    final maxTemps = daily['temperature_2m_max'] as List;
    final minTemps = daily['temperature_2m_min'] as List;
    final weatherCodes = daily['weathercode'] as List;

    final forecast = <WeatherData>[];

    for (var i = 0; i < times.length && i < maxTemps.length && i < minTemps.length; i++) {
      forecast.add(
        WeatherData(
          temperature: ((maxTemps[i] as num) + (minTemps[i] as num)) / 2,
          feelsLike: (maxTemps[i] as num).toDouble(),
          condition: _getWeatherCondition(weatherCodes[i] as int),
          humidity: 50,
          windSpeed: 0,
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
        ),
      );
    }

    return forecast;
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw WeatherException('Превышено время ожидания. Проверьте соединение.');
    }

    if (e.type == DioExceptionType.connectionError) {
      throw WeatherException('Нет соединения с интернетом.');
    }

    throw WeatherException('Ошибка сети: ${e.message}');
  }

  /// Очистить кэш
  void clearCache() {
    _cache.clear();
  }

  /// Очистить просроченные записи кэша
  void _cleanupCache() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => now.isAfter(entry.expiresAt));
  }
}

/// Исключение погодного сервиса
class WeatherException implements Exception {
  final String message;
  
  const WeatherException(this.message);
  
  @override
  String toString() => 'WeatherException: $message';
}

/// Запись кэша погоды
class _WeatherCacheEntry {
  final WeatherData data;
  final DateTime expiresAt;

  _WeatherCacheEntry({
    required this.data,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
