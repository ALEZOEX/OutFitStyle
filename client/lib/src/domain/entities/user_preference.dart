// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preference.freezed.dart';
part 'user_preference.g.dart';

@freezed
class UserPreference with _$UserPreference {
  const factory UserPreference({
    @Default('comfortable')
    @JsonKey(name: 'preferred_temperature')
    String preferredTemperature,
    @Default([])
    @JsonKey(name: 'preferred_colors')
    List<String> preferredColors,
    @Default([])
    @JsonKey(name: 'preferred_styles')
    List<String> preferredStyles,
    @Default([])
    @JsonKey(name: 'preferred_brands')
    List<String> preferredBrands,
    @Default([]) @JsonKey(name: 'excluded_items') List<String> excludedItems,
    @Default(false)
    @JsonKey(name: 'prefers_natural_materials')
    bool prefersNaturalMaterials,
    @Default(false)
    @JsonKey(name: 'prefers_synthetic_materials')
    bool prefersSyntheticMaterials,
    @Default(false) @JsonKey(name: 'sensitive_to_cold') bool sensitiveToCold,
    @Default(false) @JsonKey(name: 'sensitive_to_heat') bool sensitiveToHeat,
    @Default([])
    @JsonKey(name: 'occasions_of_interest')
    List<String> occasionsOfInterest,

    // Недостающие поля
    @JsonKey(name: 'max_budget') double? maxBudget,
    @JsonKey(name: 'fit_preference') String? fitPreference,
  }) = _UserPreference;

  factory UserPreference.fromJson(Map<String, dynamic> json) =>
      _$UserPreferenceFromJson(json);
}
