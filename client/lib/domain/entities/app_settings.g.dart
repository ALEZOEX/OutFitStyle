// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsImpl _$$AppSettingsImplFromJson(Map<String, dynamic> json) =>
    _$AppSettingsImpl(
      notificationsEnabled: json['notificationsEnabled'] as bool,
      locationEnabled: json['locationEnabled'] as bool,
      analyticsEnabled: json['analyticsEnabled'] as bool,
      darkMode: json['darkMode'] as bool,
      temperatureUnit: json['temperatureUnit'] as String,
      distanceUnit: json['distanceUnit'] as String,
      currency: json['currency'] as String,
      language: json['language'] as String,
      autoSync: json['autoSync'] as bool,
      syncInterval: (json['syncInterval'] as num).toInt(),
      premiumFeatures: json['premiumFeatures'] as bool,
      theme: json['theme'] as String,
      hapticFeedback: json['hapticFeedback'] as bool,
      soundEffects: json['soundEffects'] as bool,
      lastSync: json['lastSync'] as String,
      showWeatherOnHome: json['showWeatherOnHome'] as bool,
      showRecommendationsOnHome: json['showRecommendationsOnHome'] as bool,
      autoRefreshWeather: json['autoRefreshWeather'] as bool,
      weatherRefreshInterval: (json['weatherRefreshInterval'] as num).toInt(),
      enableOfflineMode: json['enableOfflineMode'] as bool,
      allowPersonalizedAds: json['allowPersonalizedAds'] as bool,
    );

Map<String, dynamic> _$$AppSettingsImplToJson(_$AppSettingsImpl instance) =>
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
