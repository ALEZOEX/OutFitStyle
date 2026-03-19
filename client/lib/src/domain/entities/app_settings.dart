import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(true) bool notificationsEnabled,
    @Default(true) bool locationEnabled,
    @Default(true) bool analyticsEnabled,
    @Default(false) bool darkMode,
    @Default('celsius') String temperatureUnit,
    @Default('metric') String distanceUnit,
    @Default('USD') String currency,
    @Default('en') String language,
    @Default(true) bool autoSync,
    @Default(30) int syncInterval,
    @Default(false) bool premiumFeatures,
    @Default('light') String theme,
    @Default(true) bool hapticFeedback,
    @Default(true) bool soundEffects,
    String? lastSync,
    @Default(true) bool showWeatherOnHome,
    @Default(true) bool showRecommendationsOnHome,
    @Default(true) bool autoRefreshWeather,
    @Default(60) int weatherRefreshInterval,
    @Default(false) bool enableOfflineMode,
    @Default(true) bool allowPersonalizedAds,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);
}
