import 'package:json_annotation/json_annotation.dart';

part 'trip_dto.g.dart';

/// DTO элемента в списке вещей
@JsonSerializable()
class PackingItemDto {
  final String id;
  @JsonKey(name: 'wardrobe_item_id')
  final String wardrobeItemId;
  final String name;
  final String? category;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_packed')
  final bool isPacked;
  @JsonKey(name: 'is_recommended')
  final bool isRecommended;

  const PackingItemDto({
    required this.id,
    required this.wardrobeItemId,
    required this.name,
    this.category,
    this.imageUrl,
    this.isPacked = false,
    this.isRecommended = false,
  });

  factory PackingItemDto.fromJson(Map<String, dynamic> json) {
    return _$PackingItemDtoFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$PackingItemDtoToJson(this);
  }
}

/// DTO погоды
@JsonSerializable()
class WeatherDto {
  final double temperature;
  final String condition;
  @JsonKey(name: 'feels_like')
  final double? feelsLike;
  final int? humidity;
  @JsonKey(name: 'wind_speed')
  final int? windSpeed;
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  const WeatherDto({
    required this.temperature,
    required this.condition,
    this.feelsLike,
    this.humidity,
    this.windSpeed,
    this.iconUrl,
  });

  factory WeatherDto.fromJson(Map<String, dynamic> json) {
    return _$WeatherDtoFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$WeatherDtoToJson(this);
  }
}

/// DTO поездки
@JsonSerializable()
class TripDto {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String destination;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  final List<String> occasions;
  @JsonKey(name: 'packing_list')
  final dynamic packingList;
  final String status;
  final WeatherDto? weather;
  @JsonKey(name: 'destination_lat')
  final double? destinationLat;
  @JsonKey(name: 'destination_lon')
  final double? destinationLon;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TripDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.occasions = const [],
    this.packingList,
    required this.status,
    this.weather,
    this.destinationLat,
    this.destinationLon,
    required this.createdAt,
  });

  factory TripDto.fromJson(Map<String, dynamic> json) {
    return _$TripDtoFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$TripDtoToJson(this);
  }
}
