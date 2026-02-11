// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeatherData _$WeatherDataFromJson(Map<String, dynamic> json) {
  return _WeatherData.fromJson(json);
}

/// @nodoc
mixin _$WeatherData {
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double? get temperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'feels_like')
  double? get feelsLike => throw _privateConstructorUsedError;
  int? get humidity => throw _privateConstructorUsedError;
  @JsonKey(name: 'wind_speed')
  double? get windSpeed => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_name')
  String? get locationName => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_url')
  String? get iconUrl => throw _privateConstructorUsedError;
  String? get iconCode => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  List<HourlyForecast> get hourlyForecast => throw _privateConstructorUsedError;
  List<DailyForecast> get dailyForecast => throw _privateConstructorUsedError;

  /// Serializes this WeatherData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherDataCopyWith<WeatherData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherDataCopyWith<$Res> {
  factory $WeatherDataCopyWith(
          WeatherData value, $Res Function(WeatherData) then) =
      _$WeatherDataCopyWithImpl<$Res, WeatherData>;
  @useResult
  $Res call(
      {double? latitude,
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
      List<HourlyForecast> hourlyForecast,
      List<DailyForecast> dailyForecast});
}

/// @nodoc
class _$WeatherDataCopyWithImpl<$Res, $Val extends WeatherData>
    implements $WeatherDataCopyWith<$Res> {
  _$WeatherDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? temperature = freezed,
    Object? feelsLike = freezed,
    Object? humidity = freezed,
    Object? windSpeed = freezed,
    Object? condition = freezed,
    Object? description = freezed,
    Object? locationName = freezed,
    Object? iconUrl = freezed,
    Object? iconCode = freezed,
    Object? timestamp = freezed,
    Object? hourlyForecast = null,
    Object? dailyForecast = null,
  }) {
    return _then(_value.copyWith(
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      feelsLike: freezed == feelsLike
          ? _value.feelsLike
          : feelsLike // ignore: cast_nullable_to_non_nullable
              as double?,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as int?,
      windSpeed: freezed == windSpeed
          ? _value.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconCode: freezed == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hourlyForecast: null == hourlyForecast
          ? _value.hourlyForecast
          : hourlyForecast // ignore: cast_nullable_to_non_nullable
              as List<HourlyForecast>,
      dailyForecast: null == dailyForecast
          ? _value.dailyForecast
          : dailyForecast // ignore: cast_nullable_to_non_nullable
              as List<DailyForecast>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeatherDataImplCopyWith<$Res>
    implements $WeatherDataCopyWith<$Res> {
  factory _$$WeatherDataImplCopyWith(
          _$WeatherDataImpl value, $Res Function(_$WeatherDataImpl) then) =
      __$$WeatherDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double? latitude,
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
      List<HourlyForecast> hourlyForecast,
      List<DailyForecast> dailyForecast});
}

/// @nodoc
class __$$WeatherDataImplCopyWithImpl<$Res>
    extends _$WeatherDataCopyWithImpl<$Res, _$WeatherDataImpl>
    implements _$$WeatherDataImplCopyWith<$Res> {
  __$$WeatherDataImplCopyWithImpl(
      _$WeatherDataImpl _value, $Res Function(_$WeatherDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? temperature = freezed,
    Object? feelsLike = freezed,
    Object? humidity = freezed,
    Object? windSpeed = freezed,
    Object? condition = freezed,
    Object? description = freezed,
    Object? locationName = freezed,
    Object? iconUrl = freezed,
    Object? iconCode = freezed,
    Object? timestamp = freezed,
    Object? hourlyForecast = null,
    Object? dailyForecast = null,
  }) {
    return _then(_$WeatherDataImpl(
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      temperature: freezed == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double?,
      feelsLike: freezed == feelsLike
          ? _value.feelsLike
          : feelsLike // ignore: cast_nullable_to_non_nullable
              as double?,
      humidity: freezed == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as int?,
      windSpeed: freezed == windSpeed
          ? _value.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      locationName: freezed == locationName
          ? _value.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      iconUrl: freezed == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconCode: freezed == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String?,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hourlyForecast: null == hourlyForecast
          ? _value._hourlyForecast
          : hourlyForecast // ignore: cast_nullable_to_non_nullable
              as List<HourlyForecast>,
      dailyForecast: null == dailyForecast
          ? _value._dailyForecast
          : dailyForecast // ignore: cast_nullable_to_non_nullable
              as List<DailyForecast>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherDataImpl implements _WeatherData {
  const _$WeatherDataImpl(
      {this.latitude,
      this.longitude,
      this.temperature,
      @JsonKey(name: 'feels_like') this.feelsLike,
      this.humidity,
      @JsonKey(name: 'wind_speed') this.windSpeed,
      this.condition,
      this.description,
      @JsonKey(name: 'location_name') this.locationName,
      @JsonKey(name: 'icon_url') this.iconUrl,
      this.iconCode,
      this.timestamp,
      final List<HourlyForecast> hourlyForecast = const [],
      final List<DailyForecast> dailyForecast = const []})
      : _hourlyForecast = hourlyForecast,
        _dailyForecast = dailyForecast;

  factory _$WeatherDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherDataImplFromJson(json);

  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final double? temperature;
  @override
  @JsonKey(name: 'feels_like')
  final double? feelsLike;
  @override
  final int? humidity;
  @override
  @JsonKey(name: 'wind_speed')
  final double? windSpeed;
  @override
  final String? condition;
  @override
  final String? description;
  @override
  @JsonKey(name: 'location_name')
  final String? locationName;
  @override
  @JsonKey(name: 'icon_url')
  final String? iconUrl;
  @override
  final String? iconCode;
  @override
  final DateTime? timestamp;
  final List<HourlyForecast> _hourlyForecast;
  @override
  @JsonKey()
  List<HourlyForecast> get hourlyForecast {
    if (_hourlyForecast is EqualUnmodifiableListView) return _hourlyForecast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hourlyForecast);
  }

  final List<DailyForecast> _dailyForecast;
  @override
  @JsonKey()
  List<DailyForecast> get dailyForecast {
    if (_dailyForecast is EqualUnmodifiableListView) return _dailyForecast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dailyForecast);
  }

  @override
  String toString() {
    return 'WeatherData(latitude: $latitude, longitude: $longitude, temperature: $temperature, feelsLike: $feelsLike, humidity: $humidity, windSpeed: $windSpeed, condition: $condition, description: $description, locationName: $locationName, iconUrl: $iconUrl, iconCode: $iconCode, timestamp: $timestamp, hourlyForecast: $hourlyForecast, dailyForecast: $dailyForecast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherDataImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.feelsLike, feelsLike) ||
                other.feelsLike == feelsLike) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            const DeepCollectionEquality()
                .equals(other._hourlyForecast, _hourlyForecast) &&
            const DeepCollectionEquality()
                .equals(other._dailyForecast, _dailyForecast));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      latitude,
      longitude,
      temperature,
      feelsLike,
      humidity,
      windSpeed,
      condition,
      description,
      locationName,
      iconUrl,
      iconCode,
      timestamp,
      const DeepCollectionEquality().hash(_hourlyForecast),
      const DeepCollectionEquality().hash(_dailyForecast));

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      __$$WeatherDataImplCopyWithImpl<_$WeatherDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherDataImplToJson(
      this,
    );
  }
}

abstract class _WeatherData implements WeatherData {
  const factory _WeatherData(
      {final double? latitude,
      final double? longitude,
      final double? temperature,
      @JsonKey(name: 'feels_like') final double? feelsLike,
      final int? humidity,
      @JsonKey(name: 'wind_speed') final double? windSpeed,
      final String? condition,
      final String? description,
      @JsonKey(name: 'location_name') final String? locationName,
      @JsonKey(name: 'icon_url') final String? iconUrl,
      final String? iconCode,
      final DateTime? timestamp,
      final List<HourlyForecast> hourlyForecast,
      final List<DailyForecast> dailyForecast}) = _$WeatherDataImpl;

  factory _WeatherData.fromJson(Map<String, dynamic> json) =
      _$WeatherDataImpl.fromJson;

  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  double? get temperature;
  @override
  @JsonKey(name: 'feels_like')
  double? get feelsLike;
  @override
  int? get humidity;
  @override
  @JsonKey(name: 'wind_speed')
  double? get windSpeed;
  @override
  String? get condition;
  @override
  String? get description;
  @override
  @JsonKey(name: 'location_name')
  String? get locationName;
  @override
  @JsonKey(name: 'icon_url')
  String? get iconUrl;
  @override
  String? get iconCode;
  @override
  DateTime? get timestamp;
  @override
  List<HourlyForecast> get hourlyForecast;
  @override
  List<DailyForecast> get dailyForecast;

  /// Create a copy of WeatherData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherDataImplCopyWith<_$WeatherDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HourlyForecast _$HourlyForecastFromJson(Map<String, dynamic> json) {
  return _HourlyForecast.fromJson(json);
}

/// @nodoc
mixin _$HourlyForecast {
  DateTime get time => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  String get iconCode => throw _privateConstructorUsedError;
  double get precipitationProbability => throw _privateConstructorUsedError;

  /// Serializes this HourlyForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HourlyForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyForecastCopyWith<HourlyForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyForecastCopyWith<$Res> {
  factory $HourlyForecastCopyWith(
          HourlyForecast value, $Res Function(HourlyForecast) then) =
      _$HourlyForecastCopyWithImpl<$Res, HourlyForecast>;
  @useResult
  $Res call(
      {DateTime time,
      double temperature,
      String condition,
      String iconCode,
      double precipitationProbability});
}

/// @nodoc
class _$HourlyForecastCopyWithImpl<$Res, $Val extends HourlyForecast>
    implements $HourlyForecastCopyWith<$Res> {
  _$HourlyForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? temperature = null,
    Object? condition = null,
    Object? iconCode = null,
    Object? precipitationProbability = null,
  }) {
    return _then(_value.copyWith(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String,
      precipitationProbability: null == precipitationProbability
          ? _value.precipitationProbability
          : precipitationProbability // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HourlyForecastImplCopyWith<$Res>
    implements $HourlyForecastCopyWith<$Res> {
  factory _$$HourlyForecastImplCopyWith(_$HourlyForecastImpl value,
          $Res Function(_$HourlyForecastImpl) then) =
      __$$HourlyForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime time,
      double temperature,
      String condition,
      String iconCode,
      double precipitationProbability});
}

/// @nodoc
class __$$HourlyForecastImplCopyWithImpl<$Res>
    extends _$HourlyForecastCopyWithImpl<$Res, _$HourlyForecastImpl>
    implements _$$HourlyForecastImplCopyWith<$Res> {
  __$$HourlyForecastImplCopyWithImpl(
      _$HourlyForecastImpl _value, $Res Function(_$HourlyForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of HourlyForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? time = null,
    Object? temperature = null,
    Object? condition = null,
    Object? iconCode = null,
    Object? precipitationProbability = null,
  }) {
    return _then(_$HourlyForecastImpl(
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as DateTime,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String,
      precipitationProbability: null == precipitationProbability
          ? _value.precipitationProbability
          : precipitationProbability // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HourlyForecastImpl implements _HourlyForecast {
  const _$HourlyForecastImpl(
      {required this.time,
      required this.temperature,
      required this.condition,
      required this.iconCode,
      required this.precipitationProbability});

  factory _$HourlyForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$HourlyForecastImplFromJson(json);

  @override
  final DateTime time;
  @override
  final double temperature;
  @override
  final String condition;
  @override
  final String iconCode;
  @override
  final double precipitationProbability;

  @override
  String toString() {
    return 'HourlyForecast(time: $time, temperature: $temperature, condition: $condition, iconCode: $iconCode, precipitationProbability: $precipitationProbability)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyForecastImpl &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            (identical(
                    other.precipitationProbability, precipitationProbability) ||
                other.precipitationProbability == precipitationProbability));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, time, temperature, condition,
      iconCode, precipitationProbability);

  /// Create a copy of HourlyForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyForecastImplCopyWith<_$HourlyForecastImpl> get copyWith =>
      __$$HourlyForecastImplCopyWithImpl<_$HourlyForecastImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HourlyForecastImplToJson(
      this,
    );
  }
}

abstract class _HourlyForecast implements HourlyForecast {
  const factory _HourlyForecast(
      {required final DateTime time,
      required final double temperature,
      required final String condition,
      required final String iconCode,
      required final double precipitationProbability}) = _$HourlyForecastImpl;

  factory _HourlyForecast.fromJson(Map<String, dynamic> json) =
      _$HourlyForecastImpl.fromJson;

  @override
  DateTime get time;
  @override
  double get temperature;
  @override
  String get condition;
  @override
  String get iconCode;
  @override
  double get precipitationProbability;

  /// Create a copy of HourlyForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyForecastImplCopyWith<_$HourlyForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyForecast _$DailyForecastFromJson(Map<String, dynamic> json) {
  return _DailyForecast.fromJson(json);
}

/// @nodoc
mixin _$DailyForecast {
  DateTime get date => throw _privateConstructorUsedError;
  double get maxTemp => throw _privateConstructorUsedError;
  double get minTemp => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  String get iconCode => throw _privateConstructorUsedError;
  double get precipitationProbability => throw _privateConstructorUsedError;

  /// Serializes this DailyForecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyForecastCopyWith<DailyForecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyForecastCopyWith<$Res> {
  factory $DailyForecastCopyWith(
          DailyForecast value, $Res Function(DailyForecast) then) =
      _$DailyForecastCopyWithImpl<$Res, DailyForecast>;
  @useResult
  $Res call(
      {DateTime date,
      double maxTemp,
      double minTemp,
      String condition,
      String iconCode,
      double precipitationProbability});
}

/// @nodoc
class _$DailyForecastCopyWithImpl<$Res, $Val extends DailyForecast>
    implements $DailyForecastCopyWith<$Res> {
  _$DailyForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? maxTemp = null,
    Object? minTemp = null,
    Object? condition = null,
    Object? iconCode = null,
    Object? precipitationProbability = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxTemp: null == maxTemp
          ? _value.maxTemp
          : maxTemp // ignore: cast_nullable_to_non_nullable
              as double,
      minTemp: null == minTemp
          ? _value.minTemp
          : minTemp // ignore: cast_nullable_to_non_nullable
              as double,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String,
      precipitationProbability: null == precipitationProbability
          ? _value.precipitationProbability
          : precipitationProbability // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyForecastImplCopyWith<$Res>
    implements $DailyForecastCopyWith<$Res> {
  factory _$$DailyForecastImplCopyWith(
          _$DailyForecastImpl value, $Res Function(_$DailyForecastImpl) then) =
      __$$DailyForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      double maxTemp,
      double minTemp,
      String condition,
      String iconCode,
      double precipitationProbability});
}

/// @nodoc
class __$$DailyForecastImplCopyWithImpl<$Res>
    extends _$DailyForecastCopyWithImpl<$Res, _$DailyForecastImpl>
    implements _$$DailyForecastImplCopyWith<$Res> {
  __$$DailyForecastImplCopyWithImpl(
      _$DailyForecastImpl _value, $Res Function(_$DailyForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? maxTemp = null,
    Object? minTemp = null,
    Object? condition = null,
    Object? iconCode = null,
    Object? precipitationProbability = null,
  }) {
    return _then(_$DailyForecastImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      maxTemp: null == maxTemp
          ? _value.maxTemp
          : maxTemp // ignore: cast_nullable_to_non_nullable
              as double,
      minTemp: null == minTemp
          ? _value.minTemp
          : minTemp // ignore: cast_nullable_to_non_nullable
              as double,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      iconCode: null == iconCode
          ? _value.iconCode
          : iconCode // ignore: cast_nullable_to_non_nullable
              as String,
      precipitationProbability: null == precipitationProbability
          ? _value.precipitationProbability
          : precipitationProbability // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyForecastImpl implements _DailyForecast {
  const _$DailyForecastImpl(
      {required this.date,
      required this.maxTemp,
      required this.minTemp,
      required this.condition,
      required this.iconCode,
      required this.precipitationProbability});

  factory _$DailyForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyForecastImplFromJson(json);

  @override
  final DateTime date;
  @override
  final double maxTemp;
  @override
  final double minTemp;
  @override
  final String condition;
  @override
  final String iconCode;
  @override
  final double precipitationProbability;

  @override
  String toString() {
    return 'DailyForecast(date: $date, maxTemp: $maxTemp, minTemp: $minTemp, condition: $condition, iconCode: $iconCode, precipitationProbability: $precipitationProbability)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyForecastImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.maxTemp, maxTemp) || other.maxTemp == maxTemp) &&
            (identical(other.minTemp, minTemp) || other.minTemp == minTemp) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.iconCode, iconCode) ||
                other.iconCode == iconCode) &&
            (identical(
                    other.precipitationProbability, precipitationProbability) ||
                other.precipitationProbability == precipitationProbability));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, maxTemp, minTemp,
      condition, iconCode, precipitationProbability);

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyForecastImplCopyWith<_$DailyForecastImpl> get copyWith =>
      __$$DailyForecastImplCopyWithImpl<_$DailyForecastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyForecastImplToJson(
      this,
    );
  }
}

abstract class _DailyForecast implements DailyForecast {
  const factory _DailyForecast(
      {required final DateTime date,
      required final double maxTemp,
      required final double minTemp,
      required final String condition,
      required final String iconCode,
      required final double precipitationProbability}) = _$DailyForecastImpl;

  factory _DailyForecast.fromJson(Map<String, dynamic> json) =
      _$DailyForecastImpl.fromJson;

  @override
  DateTime get date;
  @override
  double get maxTemp;
  @override
  double get minTemp;
  @override
  String get condition;
  @override
  String get iconCode;
  @override
  double get precipitationProbability;

  /// Create a copy of DailyForecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyForecastImplCopyWith<_$DailyForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
