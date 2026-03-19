import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_data.freezed.dart';
part 'weather_data.g.dart';

@freezed
abstract class WeatherData with _$WeatherData {
  const factory WeatherData({
    double? latitude,
    double? longitude,
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    String? condition,
    String? description,
    String? locationName,
    String? iconUrl,
  }) = _WeatherData;

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
}
