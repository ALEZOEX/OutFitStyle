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

 bool get notificationsEnabled; bool get locationEnabled; bool get analyticsEnabled; bool get darkMode; String get temperatureUnit; String get distanceUnit; String get currency; String get language; bool get autoSync; int get syncInterval; bool get premiumFeatures; String get theme; bool get hapticFeedback; bool get soundEffects; String? get lastSync; bool get showWeatherOnHome; bool get showRecommendationsOnHome; bool get autoRefreshWeather; int get weatherRefreshInterval; bool get enableOfflineMode; bool get allowPersonalizedAds;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.locationEnabled, locationEnabled) || other.locationEnabled == locationEnabled)&&(identical(other.analyticsEnabled, analyticsEnabled) || other.analyticsEnabled == analyticsEnabled)&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode)&&(identical(other.temperatureUnit, temperatureUnit) || other.temperatureUnit == temperatureUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.language, language) || other.language == language)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync)&&(identical(other.syncInterval, syncInterval) || other.syncInterval == syncInterval)&&(identical(other.premiumFeatures, premiumFeatures) || other.premiumFeatures == premiumFeatures)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.hapticFeedback, hapticFeedback) || other.hapticFeedback == hapticFeedback)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.lastSync, lastSync) || other.lastSync == lastSync)&&(identical(other.showWeatherOnHome, showWeatherOnHome) || other.showWeatherOnHome == showWeatherOnHome)&&(identical(other.showRecommendationsOnHome, showRecommendationsOnHome) || other.showRecommendationsOnHome == showRecommendationsOnHome)&&(identical(other.autoRefreshWeather, autoRefreshWeather) || other.autoRefreshWeather == autoRefreshWeather)&&(identical(other.weatherRefreshInterval, weatherRefreshInterval) || other.weatherRefreshInterval == weatherRefreshInterval)&&(identical(other.enableOfflineMode, enableOfflineMode) || other.enableOfflineMode == enableOfflineMode)&&(identical(other.allowPersonalizedAds, allowPersonalizedAds) || other.allowPersonalizedAds == allowPersonalizedAds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,notificationsEnabled,locationEnabled,analyticsEnabled,darkMode,temperatureUnit,distanceUnit,currency,language,autoSync,syncInterval,premiumFeatures,theme,hapticFeedback,soundEffects,lastSync,showWeatherOnHome,showRecommendationsOnHome,autoRefreshWeather,weatherRefreshInterval,enableOfflineMode,allowPersonalizedAds]);

@override
String toString() {
  return 'AppSettings(notificationsEnabled: $notificationsEnabled, locationEnabled: $locationEnabled, analyticsEnabled: $analyticsEnabled, darkMode: $darkMode, temperatureUnit: $temperatureUnit, distanceUnit: $distanceUnit, currency: $currency, language: $language, autoSync: $autoSync, syncInterval: $syncInterval, premiumFeatures: $premiumFeatures, theme: $theme, hapticFeedback: $hapticFeedback, soundEffects: $soundEffects, lastSync: $lastSync, showWeatherOnHome: $showWeatherOnHome, showRecommendationsOnHome: $showRecommendationsOnHome, autoRefreshWeather: $autoRefreshWeather, weatherRefreshInterval: $weatherRefreshInterval, enableOfflineMode: $enableOfflineMode, allowPersonalizedAds: $allowPersonalizedAds)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 bool notificationsEnabled, bool locationEnabled, bool analyticsEnabled, bool darkMode, String temperatureUnit, String distanceUnit, String currency, String language, bool autoSync, int syncInterval, bool premiumFeatures, String theme, bool hapticFeedback, bool soundEffects, String? lastSync, bool showWeatherOnHome, bool showRecommendationsOnHome, bool autoRefreshWeather, int weatherRefreshInterval, bool enableOfflineMode, bool allowPersonalizedAds
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
@pragma('vm:prefer-inline') @override $Res call({Object? notificationsEnabled = null,Object? locationEnabled = null,Object? analyticsEnabled = null,Object? darkMode = null,Object? temperatureUnit = null,Object? distanceUnit = null,Object? currency = null,Object? language = null,Object? autoSync = null,Object? syncInterval = null,Object? premiumFeatures = null,Object? theme = null,Object? hapticFeedback = null,Object? soundEffects = null,Object? lastSync = freezed,Object? showWeatherOnHome = null,Object? showRecommendationsOnHome = null,Object? autoRefreshWeather = null,Object? weatherRefreshInterval = null,Object? enableOfflineMode = null,Object? allowPersonalizedAds = null,}) {
  return _then(_self.copyWith(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,locationEnabled: null == locationEnabled ? _self.locationEnabled : locationEnabled // ignore: cast_nullable_to_non_nullable
as bool,analyticsEnabled: null == analyticsEnabled ? _self.analyticsEnabled : analyticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,temperatureUnit: null == temperatureUnit ? _self.temperatureUnit : temperatureUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,syncInterval: null == syncInterval ? _self.syncInterval : syncInterval // ignore: cast_nullable_to_non_nullable
as int,premiumFeatures: null == premiumFeatures ? _self.premiumFeatures : premiumFeatures // ignore: cast_nullable_to_non_nullable
as bool,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,hapticFeedback: null == hapticFeedback ? _self.hapticFeedback : hapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,lastSync: freezed == lastSync ? _self.lastSync : lastSync // ignore: cast_nullable_to_non_nullable
as String?,showWeatherOnHome: null == showWeatherOnHome ? _self.showWeatherOnHome : showWeatherOnHome // ignore: cast_nullable_to_non_nullable
as bool,showRecommendationsOnHome: null == showRecommendationsOnHome ? _self.showRecommendationsOnHome : showRecommendationsOnHome // ignore: cast_nullable_to_non_nullable
as bool,autoRefreshWeather: null == autoRefreshWeather ? _self.autoRefreshWeather : autoRefreshWeather // ignore: cast_nullable_to_non_nullable
as bool,weatherRefreshInterval: null == weatherRefreshInterval ? _self.weatherRefreshInterval : weatherRefreshInterval // ignore: cast_nullable_to_non_nullable
as int,enableOfflineMode: null == enableOfflineMode ? _self.enableOfflineMode : enableOfflineMode // ignore: cast_nullable_to_non_nullable
as bool,allowPersonalizedAds: null == allowPersonalizedAds ? _self.allowPersonalizedAds : allowPersonalizedAds // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool notificationsEnabled,  bool locationEnabled,  bool analyticsEnabled,  bool darkMode,  String temperatureUnit,  String distanceUnit,  String currency,  String language,  bool autoSync,  int syncInterval,  bool premiumFeatures,  String theme,  bool hapticFeedback,  bool soundEffects,  String? lastSync,  bool showWeatherOnHome,  bool showRecommendationsOnHome,  bool autoRefreshWeather,  int weatherRefreshInterval,  bool enableOfflineMode,  bool allowPersonalizedAds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.locationEnabled,_that.analyticsEnabled,_that.darkMode,_that.temperatureUnit,_that.distanceUnit,_that.currency,_that.language,_that.autoSync,_that.syncInterval,_that.premiumFeatures,_that.theme,_that.hapticFeedback,_that.soundEffects,_that.lastSync,_that.showWeatherOnHome,_that.showRecommendationsOnHome,_that.autoRefreshWeather,_that.weatherRefreshInterval,_that.enableOfflineMode,_that.allowPersonalizedAds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool notificationsEnabled,  bool locationEnabled,  bool analyticsEnabled,  bool darkMode,  String temperatureUnit,  String distanceUnit,  String currency,  String language,  bool autoSync,  int syncInterval,  bool premiumFeatures,  String theme,  bool hapticFeedback,  bool soundEffects,  String? lastSync,  bool showWeatherOnHome,  bool showRecommendationsOnHome,  bool autoRefreshWeather,  int weatherRefreshInterval,  bool enableOfflineMode,  bool allowPersonalizedAds)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.notificationsEnabled,_that.locationEnabled,_that.analyticsEnabled,_that.darkMode,_that.temperatureUnit,_that.distanceUnit,_that.currency,_that.language,_that.autoSync,_that.syncInterval,_that.premiumFeatures,_that.theme,_that.hapticFeedback,_that.soundEffects,_that.lastSync,_that.showWeatherOnHome,_that.showRecommendationsOnHome,_that.autoRefreshWeather,_that.weatherRefreshInterval,_that.enableOfflineMode,_that.allowPersonalizedAds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool notificationsEnabled,  bool locationEnabled,  bool analyticsEnabled,  bool darkMode,  String temperatureUnit,  String distanceUnit,  String currency,  String language,  bool autoSync,  int syncInterval,  bool premiumFeatures,  String theme,  bool hapticFeedback,  bool soundEffects,  String? lastSync,  bool showWeatherOnHome,  bool showRecommendationsOnHome,  bool autoRefreshWeather,  int weatherRefreshInterval,  bool enableOfflineMode,  bool allowPersonalizedAds)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.notificationsEnabled,_that.locationEnabled,_that.analyticsEnabled,_that.darkMode,_that.temperatureUnit,_that.distanceUnit,_that.currency,_that.language,_that.autoSync,_that.syncInterval,_that.premiumFeatures,_that.theme,_that.hapticFeedback,_that.soundEffects,_that.lastSync,_that.showWeatherOnHome,_that.showRecommendationsOnHome,_that.autoRefreshWeather,_that.weatherRefreshInterval,_that.enableOfflineMode,_that.allowPersonalizedAds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({this.notificationsEnabled = true, this.locationEnabled = true, this.analyticsEnabled = true, this.darkMode = false, this.temperatureUnit = 'celsius', this.distanceUnit = 'metric', this.currency = 'USD', this.language = 'en', this.autoSync = true, this.syncInterval = 30, this.premiumFeatures = false, this.theme = 'light', this.hapticFeedback = true, this.soundEffects = true, this.lastSync, this.showWeatherOnHome = true, this.showRecommendationsOnHome = true, this.autoRefreshWeather = true, this.weatherRefreshInterval = 60, this.enableOfflineMode = false, this.allowPersonalizedAds = true});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  bool notificationsEnabled;
@override@JsonKey() final  bool locationEnabled;
@override@JsonKey() final  bool analyticsEnabled;
@override@JsonKey() final  bool darkMode;
@override@JsonKey() final  String temperatureUnit;
@override@JsonKey() final  String distanceUnit;
@override@JsonKey() final  String currency;
@override@JsonKey() final  String language;
@override@JsonKey() final  bool autoSync;
@override@JsonKey() final  int syncInterval;
@override@JsonKey() final  bool premiumFeatures;
@override@JsonKey() final  String theme;
@override@JsonKey() final  bool hapticFeedback;
@override@JsonKey() final  bool soundEffects;
@override final  String? lastSync;
@override@JsonKey() final  bool showWeatherOnHome;
@override@JsonKey() final  bool showRecommendationsOnHome;
@override@JsonKey() final  bool autoRefreshWeather;
@override@JsonKey() final  int weatherRefreshInterval;
@override@JsonKey() final  bool enableOfflineMode;
@override@JsonKey() final  bool allowPersonalizedAds;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.notificationsEnabled, notificationsEnabled) || other.notificationsEnabled == notificationsEnabled)&&(identical(other.locationEnabled, locationEnabled) || other.locationEnabled == locationEnabled)&&(identical(other.analyticsEnabled, analyticsEnabled) || other.analyticsEnabled == analyticsEnabled)&&(identical(other.darkMode, darkMode) || other.darkMode == darkMode)&&(identical(other.temperatureUnit, temperatureUnit) || other.temperatureUnit == temperatureUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.language, language) || other.language == language)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync)&&(identical(other.syncInterval, syncInterval) || other.syncInterval == syncInterval)&&(identical(other.premiumFeatures, premiumFeatures) || other.premiumFeatures == premiumFeatures)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.hapticFeedback, hapticFeedback) || other.hapticFeedback == hapticFeedback)&&(identical(other.soundEffects, soundEffects) || other.soundEffects == soundEffects)&&(identical(other.lastSync, lastSync) || other.lastSync == lastSync)&&(identical(other.showWeatherOnHome, showWeatherOnHome) || other.showWeatherOnHome == showWeatherOnHome)&&(identical(other.showRecommendationsOnHome, showRecommendationsOnHome) || other.showRecommendationsOnHome == showRecommendationsOnHome)&&(identical(other.autoRefreshWeather, autoRefreshWeather) || other.autoRefreshWeather == autoRefreshWeather)&&(identical(other.weatherRefreshInterval, weatherRefreshInterval) || other.weatherRefreshInterval == weatherRefreshInterval)&&(identical(other.enableOfflineMode, enableOfflineMode) || other.enableOfflineMode == enableOfflineMode)&&(identical(other.allowPersonalizedAds, allowPersonalizedAds) || other.allowPersonalizedAds == allowPersonalizedAds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,notificationsEnabled,locationEnabled,analyticsEnabled,darkMode,temperatureUnit,distanceUnit,currency,language,autoSync,syncInterval,premiumFeatures,theme,hapticFeedback,soundEffects,lastSync,showWeatherOnHome,showRecommendationsOnHome,autoRefreshWeather,weatherRefreshInterval,enableOfflineMode,allowPersonalizedAds]);

@override
String toString() {
  return 'AppSettings(notificationsEnabled: $notificationsEnabled, locationEnabled: $locationEnabled, analyticsEnabled: $analyticsEnabled, darkMode: $darkMode, temperatureUnit: $temperatureUnit, distanceUnit: $distanceUnit, currency: $currency, language: $language, autoSync: $autoSync, syncInterval: $syncInterval, premiumFeatures: $premiumFeatures, theme: $theme, hapticFeedback: $hapticFeedback, soundEffects: $soundEffects, lastSync: $lastSync, showWeatherOnHome: $showWeatherOnHome, showRecommendationsOnHome: $showRecommendationsOnHome, autoRefreshWeather: $autoRefreshWeather, weatherRefreshInterval: $weatherRefreshInterval, enableOfflineMode: $enableOfflineMode, allowPersonalizedAds: $allowPersonalizedAds)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 bool notificationsEnabled, bool locationEnabled, bool analyticsEnabled, bool darkMode, String temperatureUnit, String distanceUnit, String currency, String language, bool autoSync, int syncInterval, bool premiumFeatures, String theme, bool hapticFeedback, bool soundEffects, String? lastSync, bool showWeatherOnHome, bool showRecommendationsOnHome, bool autoRefreshWeather, int weatherRefreshInterval, bool enableOfflineMode, bool allowPersonalizedAds
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
@override @pragma('vm:prefer-inline') $Res call({Object? notificationsEnabled = null,Object? locationEnabled = null,Object? analyticsEnabled = null,Object? darkMode = null,Object? temperatureUnit = null,Object? distanceUnit = null,Object? currency = null,Object? language = null,Object? autoSync = null,Object? syncInterval = null,Object? premiumFeatures = null,Object? theme = null,Object? hapticFeedback = null,Object? soundEffects = null,Object? lastSync = freezed,Object? showWeatherOnHome = null,Object? showRecommendationsOnHome = null,Object? autoRefreshWeather = null,Object? weatherRefreshInterval = null,Object? enableOfflineMode = null,Object? allowPersonalizedAds = null,}) {
  return _then(_AppSettings(
notificationsEnabled: null == notificationsEnabled ? _self.notificationsEnabled : notificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,locationEnabled: null == locationEnabled ? _self.locationEnabled : locationEnabled // ignore: cast_nullable_to_non_nullable
as bool,analyticsEnabled: null == analyticsEnabled ? _self.analyticsEnabled : analyticsEnabled // ignore: cast_nullable_to_non_nullable
as bool,darkMode: null == darkMode ? _self.darkMode : darkMode // ignore: cast_nullable_to_non_nullable
as bool,temperatureUnit: null == temperatureUnit ? _self.temperatureUnit : temperatureUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,syncInterval: null == syncInterval ? _self.syncInterval : syncInterval // ignore: cast_nullable_to_non_nullable
as int,premiumFeatures: null == premiumFeatures ? _self.premiumFeatures : premiumFeatures // ignore: cast_nullable_to_non_nullable
as bool,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,hapticFeedback: null == hapticFeedback ? _self.hapticFeedback : hapticFeedback // ignore: cast_nullable_to_non_nullable
as bool,soundEffects: null == soundEffects ? _self.soundEffects : soundEffects // ignore: cast_nullable_to_non_nullable
as bool,lastSync: freezed == lastSync ? _self.lastSync : lastSync // ignore: cast_nullable_to_non_nullable
as String?,showWeatherOnHome: null == showWeatherOnHome ? _self.showWeatherOnHome : showWeatherOnHome // ignore: cast_nullable_to_non_nullable
as bool,showRecommendationsOnHome: null == showRecommendationsOnHome ? _self.showRecommendationsOnHome : showRecommendationsOnHome // ignore: cast_nullable_to_non_nullable
as bool,autoRefreshWeather: null == autoRefreshWeather ? _self.autoRefreshWeather : autoRefreshWeather // ignore: cast_nullable_to_non_nullable
as bool,weatherRefreshInterval: null == weatherRefreshInterval ? _self.weatherRefreshInterval : weatherRefreshInterval // ignore: cast_nullable_to_non_nullable
as int,enableOfflineMode: null == enableOfflineMode ? _self.enableOfflineMode : enableOfflineMode // ignore: cast_nullable_to_non_nullable
as bool,allowPersonalizedAds: null == allowPersonalizedAds ? _self.allowPersonalizedAds : allowPersonalizedAds // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
