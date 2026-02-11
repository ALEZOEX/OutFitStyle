// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherDataImpl _$$WeatherDataImplFromJson(Map<String, dynamic> json) =>
    _$WeatherDataImpl(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      feelsLike: (json['feels_like'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toInt(),
      windSpeed: (json['wind_speed'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      description: json['description'] as String?,
      locationName: json['location_name'] as String?,
      iconUrl: json['icon_url'] as String?,
      iconCode: json['iconCode'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      hourlyForecast: (json['hourlyForecast'] as List<dynamic>?)
              ?.map((e) => HourlyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      dailyForecast: (json['dailyForecast'] as List<dynamic>?)
              ?.map((e) => DailyForecast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WeatherDataImplToJson(_$WeatherDataImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'temperature': instance.temperature,
      'feels_like': instance.feelsLike,
      'humidity': instance.humidity,
      'wind_speed': instance.windSpeed,
      'condition': instance.condition,
      'description': instance.description,
      'location_name': instance.locationName,
      'icon_url': instance.iconUrl,
      'iconCode': instance.iconCode,
      'timestamp': instance.timestamp?.toIso8601String(),
      'hourlyForecast': instance.hourlyForecast,
      'dailyForecast': instance.dailyForecast,
    };

_$HourlyForecastImpl _$$HourlyForecastImplFromJson(Map<String, dynamic> json) =>
    _$HourlyForecastImpl(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      iconCode: json['iconCode'] as String,
      precipitationProbability:
          (json['precipitationProbability'] as num).toDouble(),
    );

Map<String, dynamic> _$$HourlyForecastImplToJson(
        _$HourlyForecastImpl instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'temperature': instance.temperature,
      'condition': instance.condition,
      'iconCode': instance.iconCode,
      'precipitationProbability': instance.precipitationProbability,
    };

_$DailyForecastImpl _$$DailyForecastImplFromJson(Map<String, dynamic> json) =>
    _$DailyForecastImpl(
      date: DateTime.parse(json['date'] as String),
      maxTemp: (json['maxTemp'] as num).toDouble(),
      minTemp: (json['minTemp'] as num).toDouble(),
      condition: json['condition'] as String,
      iconCode: json['iconCode'] as String,
      precipitationProbability:
          (json['precipitationProbability'] as num).toDouble(),
    );

Map<String, dynamic> _$$DailyForecastImplToJson(_$DailyForecastImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'maxTemp': instance.maxTemp,
      'minTemp': instance.minTemp,
      'condition': instance.condition,
      'iconCode': instance.iconCode,
      'precipitationProbability': instance.precipitationProbability,
    };
