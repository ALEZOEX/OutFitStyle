// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  locationEnabled: json['locationEnabled'] as bool? ?? true,
  analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
  darkMode: json['darkMode'] as bool? ?? false,
  temperatureUnit: json['temperatureUnit'] as String? ?? 'celsius',
  distanceUnit: json['distanceUnit'] as String? ?? 'metric',
  currency: json['currency'] as String? ?? 'USD',
  language: json['language'] as String? ?? 'en',
  autoSync: json['autoSync'] as bool? ?? true,
  syncInterval: (json['syncInterval'] as num?)?.toInt() ?? 30,
  premiumFeatures: json['premiumFeatures'] as bool? ?? false,
  theme: json['theme'] as String? ?? 'light',
  hapticFeedback: json['hapticFeedback'] as bool? ?? true,
  soundEffects: json['soundEffects'] as bool? ?? true,
  lastSync: json['lastSync'] as String?,
  showWeatherOnHome: json['showWeatherOnHome'] as bool? ?? true,
  showRecommendationsOnHome: json['showRecommendationsOnHome'] as bool? ?? true,
  autoRefreshWeather: json['autoRefreshWeather'] as bool? ?? true,
  weatherRefreshInterval:
      (json['weatherRefreshInterval'] as num?)?.toInt() ?? 60,
  enableOfflineMode: json['enableOfflineMode'] as bool? ?? false,
  allowPersonalizedAds: json['allowPersonalizedAds'] as bool? ?? true,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'notificationsEnabled': instance.notificationsEnabled,
      'locationEnabled': instance.locationEnabled,
      'analyticsEnabled': instance.analyticsEnabled,
      'darkMode': instance.darkMode,
      'temperatureUnit': instance.temperatureUnit,
      'distanceUnit': instance.distanceUnit,
      'currency': instance.currency,
      'language': instance.language,
      'autoSync': instance.autoSync,
      'syncInterval': instance.syncInterval,
      'premiumFeatures': instance.premiumFeatures,
      'theme': instance.theme,
      'hapticFeedback': instance.hapticFeedback,
      'soundEffects': instance.soundEffects,
      'lastSync': instance.lastSync,
      'showWeatherOnHome': instance.showWeatherOnHome,
      'showRecommendationsOnHome': instance.showRecommendationsOnHome,
      'autoRefreshWeather': instance.autoRefreshWeather,
      'weatherRefreshInterval': instance.weatherRefreshInterval,
      'enableOfflineMode': instance.enableOfflineMode,
      'allowPersonalizedAds': instance.allowPersonalizedAds,
    };
