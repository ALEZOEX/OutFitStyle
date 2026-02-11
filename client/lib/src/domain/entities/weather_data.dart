// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

@freezed
class WeatherData with _$WeatherData {
  const factory WeatherData({
    double? latitude,
    double? longitude,
    double? temperature,
    @JsonKey(name: 'feels_like') double? feelsLike,
    int? humidity,
    @JsonKey(name: 'wind_speed') double? windSpeed,
    String? condition,
    String? description,
    @JsonKey(name: 'location_name') String? locationName,
    @JsonKey(name: 'icon_url') String? iconUrl,
    String? iconCode,
    DateTime? timestamp,
    @Default([]) List<HourlyForecast> hourlyForecast,
    @Default([]) List<DailyForecast> dailyForecast,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
}

@freezed
class HourlyForecast with _$HourlyForecast {
  const factory HourlyForecast({
    required DateTime time,
    required double temperature,
    required String condition,
    required String iconCode,
    required double precipitationProbability,
  }) = _HourlyForecast;

  factory HourlyForecast.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastFromJson(json);
}

@freezed
class DailyForecast with _$DailyForecast {
  const factory DailyForecast({
    required DateTime date,
    required double maxTemp,
    required double minTemp,
    required String condition,
    required String iconCode,
    required double precipitationProbability,
  }) = _DailyForecast;

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);
}
