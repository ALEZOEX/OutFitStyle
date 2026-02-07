// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppSettings {

 bool get notificationsEnabled; bool get locationServicesEnabled; String get temperatureUnit;// 'celsius' or 'fahrenheit'
 String get distanceUnit;// 'metric' or 'imperial'
 String get languageCode; String get themeMode;// 'light', 'dark', or 'system'
 bool get analyticsEnabled; bool get personalizationEnabled; int get autoSyncIntervalMinutes; bool get wifiOnlySync; bool get batteryOptimizationEnabled; int get forecastDays;// Number of days to show in forecast
 bool get showDetailedWeather; bool get enableHapticFeedback; bool get enableSoundEffects; Map<String, dynamic>? get customSettings;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.locationServicesEnabled, locationServicesEnabled) || other.locationServicesEnabled == locationServicesEnabled)&&(identical(other.temperatureUnit, temperatureUnit) || other.temperatureUnit == temperatureUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.analyticsEnabled, analyticsEnabled) || other.analyticsEnabled == analyticsEnabled)&&(identical(other.personalizationEnabled, personalizationEnabled) || other.personalizationEnabled == personalizationEnabled)&&(identical(other.autoSyncIntervalMinutes, autoSyncIntervalMinutes) || other.autoSyncIntervalMinutes == autoSyncIntervalMinutes)&&(identical(other.wifiOnlySync, wifiOnlySync) || other.wifiOnlySync == wifiOnlySync)&&(identical(other.batteryOptimizationEnabled, batteryOptimizationEnabled) || other.batteryOptimizationEnabled == batteryOptimizationEnabled)&&(identical(other.forecastDays, forecastDays) || other.forecastDays == forecastDays)&&(identical(other.showDetailedWeather, showDetailedWeather) || other.showDetailedWeather == showDetailedWeather)&&(identical(other.enableHapticFeedback, enableHapticFeedback) || other.enableHapticFeedback == enableHapticFeedback)&&(identical(other.enableSoundEffects, enableSoundEffects) || other.enableSoundEffects == enableSoundEffects)&&const DeepCollectionEquality().equals(other.customSettings, customSettings));
}


@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,locationServicesEnabled,temperatureUnit,distanceUnit,languageCode,themeMode,analyticsEnabled,personalizationEnabled,autoSyncIntervalMinutes,wifiOnlySync,batteryOptimizationEnabled,forecastDays,showDetailedWeather,enableHapticFeedback,enableSoundEffects,const DeepCollectionEquality().hash(customSettings));

@override
String toString() {
  return 'AppSettings(notificationsEnabled: $notificationsEnabled, locationServicesEnabled: $locationServicesEnabled, temperatureUnit: $temperatureUnit, distanceUnit: $distanceUnit, languageCode: $languageCode, themeMode: $themeMode, analyticsEnabled: $analyticsEnabled, personalizationEnabled: $personalizationEnabled, autoSyncIntervalMinutes: $autoSyncIntervalMinutes, wifiOnlySync: $wifiOnlySync, batteryOptimizationEnabled: $batteryOptimizationEnabled, forecastDays: $forecastDays, showDetailedWeather: $showDetailedWeather, enableHapticFeedback: $enableHapticFeedback, enableSoundEffects: $enableSoundEffects, customSettings: $customSettings)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool notificationsEnabled, bool locationServicesEnabled, String temperatureUnit, String distanceUnit, String languageCode, String themeMode, bool analyticsEnabled, bool personalizationEnabled, int autoSyncIntervalMinutes, bool wifiOnlySync, bool batteryOptimizationEnabled, int forecastDays, bool showDetailedWeather, bool enableHapticFeedback, bool enableSoundEffects, Map<String, dynamic>? customSettings
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notificationsEnabled = null,Object? locationServicesEnabled = null,Object? temperatureUnit = null,Object? distanceUnit = null,Object? languageCode = null,Object? themeMode = null,Object? analyticsEnabled = null,Object? personalizationEnabled = null,Object? autoSyncIntervalMinutes = null,Object? wifiOnlySync = null,Object? batteryOptimizationEnabled = null,Object? forecastDays = null,Object? showDetailedWeather = null,Object? enableHapticFeedback = null,Object? enableSoundEffects = null,Object? customSettings = freezed,}) {
  return _then(_self.copyWith(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,locationServicesEnabled: null == locationServicesEnabled ? _self.locationServicesEnabled : locationServicesEnabled // ignore: cast_nullable_to_non_nullable
as bool,temperatureUnit: null == temperatureUnit ? _self.temperatureUnit : temperatureUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,analyticsEnabled: null == analyticsEnabled ? _self.analyticsEnabled : analyticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,personalizationEnabled: null == personalizationEnabled ? _self.personalizationEnabled : personalizationEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoSyncIntervalMinutes: null == autoSyncIntervalMinutes ? _self.autoSyncIntervalMinutes : autoSyncIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,wifiOnlySync: null == wifiOnlySync ? _self.wifiOnlySync : wifiOnlySync // ignore: cast_nullable_to_non_nullable
as bool,batteryOptimizationEnabled: null == batteryOptimizationEnabled ? _self.batteryOptimizationEnabled : batteryOptimizationEnabled // ignore: cast_nullable_to_non_nullable
as bool,forecastDays: null == forecastDays ? _self.forecastDays : forecastDays // ignore: cast_nullable_to_non_nullable
as int,showDetailedWeather: null == showDetailedWeather ? _self.showDetailedWeather : showDetailedWeather // ignore: cast_nullable_to_non_nullable
as bool,enableHapticFeedback: null == enableHapticFeedback ? _self.enableHapticFeedback : enableHapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,enableSoundEffects: null == enableSoundEffects ? _self.enableSoundEffects : enableSoundEffects // ignore: cast_nullable_to_non_nullable
as bool,customSettings: freezed == customSettings ? _self.customSettings : customSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool notificationsEnabled,  bool locationServicesEnabled,  String temperatureUnit,  String distanceUnit,  String languageCode,  String themeMode,  bool analyticsEnabled,  bool personalizationEnabled,  int autoSyncIntervalMinutes,  bool wifiOnlySync,  bool batteryOptimizationEnabled,  int forecastDays,  bool showDetailedWeather,  bool enableHapticFeedback,  bool enableSoundEffects,  Map<String, dynamic>? customSettings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.locationServicesEnabled,_that.temperatureUnit,_that.distanceUnit,_that.languageCode,_that.themeMode,_that.analyticsEnabled,_that.personalizationEnabled,_that.autoSyncIntervalMinutes,_that.wifiOnlySync,_that.batteryOptimizationEnabled,_that.forecastDays,_that.showDetailedWeather,_that.enableHapticFeedback,_that.enableSoundEffects,_that.customSettings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool notificationsEnabled,  bool locationServicesEnabled,  String temperatureUnit,  String distanceUnit,  String languageCode,  String themeMode,  bool analyticsEnabled,  bool personalizationEnabled,  int autoSyncIntervalMinutes,  bool wifiOnlySync,  bool batteryOptimizationEnabled,  int forecastDays,  bool showDetailedWeather,  bool enableHapticFeedback,  bool enableSoundEffects,  Map<String, dynamic>? customSettings)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.notificationsEnabled,_that.locationServicesEnabled,_that.temperatureUnit,_that.distanceUnit,_that.languageCode,_that.themeMode,_that.analyticsEnabled,_that.personalizationEnabled,_that.autoSyncIntervalMinutes,_that.wifiOnlySync,_that.batteryOptimizationEnabled,_that.forecastDays,_that.showDetailedWeather,_that.enableHapticFeedback,_that.enableSoundEffects,_that.customSettings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool notificationsEnabled,  bool locationServicesEnabled,  String temperatureUnit,  String distanceUnit,  String languageCode,  String themeMode,  bool analyticsEnabled,  bool personalizationEnabled,  int autoSyncIntervalMinutes,  bool wifiOnlySync,  bool batteryOptimizationEnabled,  int forecastDays,  bool showDetailedWeather,  bool enableHapticFeedback,  bool enableSoundEffects,  Map<String, dynamic>? customSettings)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.locationServicesEnabled,_that.temperatureUnit,_that.distanceUnit,_that.languageCode,_that.themeMode,_that.analyticsEnabled,_that.personalizationEnabled,_that.autoSyncIntervalMinutes,_that.wifiOnlySync,_that.batteryOptimizationEnabled,_that.forecastDays,_that.showDetailedWeather,_that.enableHapticFeedback,_that.enableSoundEffects,_that.customSettings);case _:
  return null;

}
}

}

/// @nodoc


class _AppSettings implements AppSettings {
  const _AppSettings({required this.notificationsEnabled, required this.locationServicesEnabled, required this.temperatureUnit, required this.distanceUnit, required this.languageCode, required this.themeMode, required this.analyticsEnabled, required this.personalizationEnabled, required this.autoSyncIntervalMinutes, required this.wifiOnlySync, required this.batteryOptimizationEnabled, required this.forecastDays, required this.showDetailedWeather, required this.enableHapticFeedback, required this.enableSoundEffects, required final  Map<String, dynamic>? customSettings}): _customSettings = customSettings;
  

@override final  bool notificationsEnabled;
@override final  bool locationServicesEnabled;
@override final  String temperatureUnit;
// 'celsius' or 'fahrenheit'
@override final  String distanceUnit;
// 'metric' or 'imperial'
@override final  String languageCode;
@override final  String themeMode;
// 'light', 'dark', or 'system'
@override final  bool analyticsEnabled;
@override final  bool personalizationEnabled;
@override final  int autoSyncIntervalMinutes;
@override final  bool wifiOnlySync;
@override final  bool batteryOptimizationEnabled;
@override final  int forecastDays;
// Number of days to show in forecast
@override final  bool showDetailedWeather;
@override final  bool enableHapticFeedback;
@override final  bool enableSoundEffects;
 final  Map<String, dynamic>? _customSettings;
@override Map<String, dynamic>? get customSettings {
  final value = _customSettings;
  if (value == null) return null;
  if (_customSettings is EqualUnmodifiableMapView) return _customSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.locationServicesEnabled, locationServicesEnabled) || other.locationServicesEnabled == locationServicesEnabled)&&(identical(other.temperatureUnit, temperatureUnit) || other.temperatureUnit == temperatureUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.analyticsEnabled, analyticsEnabled) || other.analyticsEnabled == analyticsEnabled)&&(identical(other.personalizationEnabled, personalizationEnabled) || other.personalizationEnabled == personalizationEnabled)&&(identical(other.autoSyncIntervalMinutes, autoSyncIntervalMinutes) || other.autoSyncIntervalMinutes == autoSyncIntervalMinutes)&&(identical(other.wifiOnlySync, wifiOnlySync) || other.wifiOnlySync == wifiOnlySync)&&(identical(other.batteryOptimizationEnabled, batteryOptimizationEnabled) || other.batteryOptimizationEnabled == batteryOptimizationEnabled)&&(identical(other.forecastDays, forecastDays) || other.forecastDays == forecastDays)&&(identical(other.showDetailedWeather, showDetailedWeather) || other.showDetailedWeather == showDetailedWeather)&&(identical(other.enableHapticFeedback, enableHapticFeedback) || other.enableHapticFeedback == enableHapticFeedback)&&(identical(other.enableSoundEffects, enableSoundEffects) || other.enableSoundEffects == enableSoundEffects)&&const DeepCollectionEquality().equals(other._customSettings, _customSettings));
}


@override
int get hashCode => Object.hash(runtimeType,notificationsEnabled,locationServicesEnabled,temperatureUnit,distanceUnit,languageCode,themeMode,analyticsEnabled,personalizationEnabled,autoSyncIntervalMinutes,wifiOnlySync,batteryOptimizationEnabled,forecastDays,showDetailedWeather,enableHapticFeedback,enableSoundEffects,const DeepCollectionEquality().hash(_customSettings));

@override
String toString() {
  return 'AppSettings(notificationsEnabled: $notificationsEnabled, locationServicesEnabled: $locationServicesEnabled, temperatureUnit: $temperatureUnit, distanceUnit: $distanceUnit, languageCode: $languageCode, themeMode: $themeMode, analyticsEnabled: $analyticsEnabled, personalizationEnabled: $personalizationEnabled, autoSyncIntervalMinutes: $autoSyncIntervalMinutes, wifiOnlySync: $wifiOnlySync, batteryOptimizationEnabled: $batteryOptimizationEnabled, forecastDays: $forecastDays, showDetailedWeather: $showDetailedWeather, enableHapticFeedback: $enableHapticFeedback, enableSoundEffects: $enableSoundEffects, customSettings: $customSettings)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool notificationsEnabled, bool locationServicesEnabled, String temperatureUnit, String distanceUnit, String languageCode, String themeMode, bool analyticsEnabled, bool personalizationEnabled, int autoSyncIntervalMinutes, bool wifiOnlySync, bool batteryOptimizationEnabled, int forecastDays, bool showDetailedWeather, bool enableHapticFeedback, bool enableSoundEffects, Map<String, dynamic>? customSettings
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notificationsEnabled = null,Object? locationServicesEnabled = null,Object? temperatureUnit = null,Object? distanceUnit = null,Object? languageCode = null,Object? themeMode = null,Object? analyticsEnabled = null,Object? personalizationEnabled = null,Object? autoSyncIntervalMinutes = null,Object? wifiOnlySync = null,Object? batteryOptimizationEnabled = null,Object? forecastDays = null,Object? showDetailedWeather = null,Object? enableHapticFeedback = null,Object? enableSoundEffects = null,Object? customSettings = freezed,}) {
  return _then(_AppSettings(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,locationServicesEnabled: null == locationServicesEnabled ? _self.locationServicesEnabled : locationServicesEnabled // ignore: cast_nullable_to_non_nullable
as bool,temperatureUnit: null == temperatureUnit ? _self.temperatureUnit : temperatureUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as String,analyticsEnabled: null == analyticsEnabled ? _self.analyticsEnabled : analyticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,personalizationEnabled: null == personalizationEnabled ? _self.personalizationEnabled : personalizationEnabled // ignore: cast_nullable_to_non_nullable
as bool,autoSyncIntervalMinutes: null == autoSyncIntervalMinutes ? _self.autoSyncIntervalMinutes : autoSyncIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,wifiOnlySync: null == wifiOnlySync ? _self.wifiOnlySync : wifiOnlySync // ignore: cast_nullable_to_non_nullable
as bool,batteryOptimizationEnabled: null == batteryOptimizationEnabled ? _self.batteryOptimizationEnabled : batteryOptimizationEnabled // ignore: cast_nullable_to_non_nullable
as bool,forecastDays: null == forecastDays ? _self.forecastDays : forecastDays // ignore: cast_nullable_to_non_nullable
as int,showDetailedWeather: null == showDetailedWeather ? _self.showDetailedWeather : showDetailedWeather // ignore: cast_nullable_to_non_nullable
as bool,enableHapticFeedback: null == enableHapticFeedback ? _self.enableHapticFeedback : enableHapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,enableSoundEffects: null == enableSoundEffects ? _self.enableSoundEffects : enableSoundEffects // ignore: cast_nullable_to_non_nullable
as bool,customSettings: freezed == customSettings ? _self._customSettings : customSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
