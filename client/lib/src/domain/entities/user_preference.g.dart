// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserPreference _$UserPreferenceFromJson(Map<String, dynamic> json) =>
    _UserPreference(
      preferredTemperature:
          json['preferred_temperature'] as String? ?? 'comfortable',
      preferredColors:
          (json['preferred_colors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredStyles:
          (json['preferred_styles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredBrands:
          (json['preferred_brands'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludedItems:
          (json['excluded_items'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      prefersNaturalMaterials:
          json['prefers_natural_materials'] as bool? ?? false,
      prefersSyntheticMaterials:
          json['prefers_synthetic_materials'] as bool? ?? false,
      sensitiveToCold: json['sensitive_to_cold'] as bool? ?? false,
      sensitiveToHeat: json['sensitive_to_heat'] as bool? ?? false,
      occasionsOfInterest:
          (json['occasions_of_interest'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      maxBudget: (json['max_budget'] as num?)?.toDouble(),
      fitPreference: json['fit_preference'] as String?,
    );

Map<String, dynamic> _$UserPreferenceToJson(_UserPreference instance) =>
    <String, dynamic>{
      'preferred_temperature': instance.preferredTemperature,
      'preferred_colors': instance.preferredColors,
      'preferred_styles': instance.preferredStyles,
      'preferred_brands': instance.preferredBrands,
      'excluded_items': instance.excludedItems,
      'prefers_natural_materials': instance.prefersNaturalMaterials,
      'prefers_synthetic_materials': instance.prefersSyntheticMaterials,
      'sensitive_to_cold': instance.sensitiveToCold,
      'sensitive_to_heat': instance.sensitiveToHeat,
      'occasions_of_interest': instance.occasionsOfInterest,
      'max_budget': instance.maxBudget,
      'fit_preference': instance.fitPreference,
    };
