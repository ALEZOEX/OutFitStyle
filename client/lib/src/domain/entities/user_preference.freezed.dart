// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreference _$UserPreferenceFromJson(Map<String, dynamic> json) {
  return _UserPreference.fromJson(json);
}

/// @nodoc
mixin _$UserPreference {
  @JsonKey(name: 'preferred_temperature')
  String get preferredTemperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_colors')
  List<String> get preferredColors => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_styles')
  List<String> get preferredStyles => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_brands')
  List<String> get preferredBrands => throw _privateConstructorUsedError;
  @JsonKey(name: 'excluded_items')
  List<String> get excludedItems => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefers_natural_materials')
  bool get prefersNaturalMaterials => throw _privateConstructorUsedError;
  @JsonKey(name: 'prefers_synthetic_materials')
  bool get prefersSyntheticMaterials => throw _privateConstructorUsedError;
  @JsonKey(name: 'sensitive_to_cold')
  bool get sensitiveToCold => throw _privateConstructorUsedError;
  @JsonKey(name: 'sensitive_to_heat')
  bool get sensitiveToHeat => throw _privateConstructorUsedError;
  @JsonKey(name: 'occasions_of_interest')
  List<String> get occasionsOfInterest =>
      throw _privateConstructorUsedError; // Недостающие поля
  @JsonKey(name: 'max_budget')
  double? get maxBudget => throw _privateConstructorUsedError;
  @JsonKey(name: 'fit_preference')
  String? get fitPreference => throw _privateConstructorUsedError;

  /// Serializes this UserPreference to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferenceCopyWith<UserPreference> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferenceCopyWith<$Res> {
  factory $UserPreferenceCopyWith(
          UserPreference value, $Res Function(UserPreference) then) =
      _$UserPreferenceCopyWithImpl<$Res, UserPreference>;
  @useResult
  $Res call(
      {@JsonKey(name: 'preferred_temperature') String preferredTemperature,
      @JsonKey(name: 'preferred_colors') List<String> preferredColors,
      @JsonKey(name: 'preferred_styles') List<String> preferredStyles,
      @JsonKey(name: 'preferred_brands') List<String> preferredBrands,
      @JsonKey(name: 'excluded_items') List<String> excludedItems,
      @JsonKey(name: 'prefers_natural_materials') bool prefersNaturalMaterials,
      @JsonKey(name: 'prefers_synthetic_materials')
      bool prefersSyntheticMaterials,
      @JsonKey(name: 'sensitive_to_cold') bool sensitiveToCold,
      @JsonKey(name: 'sensitive_to_heat') bool sensitiveToHeat,
      @JsonKey(name: 'occasions_of_interest') List<String> occasionsOfInterest,
      @JsonKey(name: 'max_budget') double? maxBudget,
      @JsonKey(name: 'fit_preference') String? fitPreference});
}

/// @nodoc
class _$UserPreferenceCopyWithImpl<$Res, $Val extends UserPreference>
    implements $UserPreferenceCopyWith<$Res> {
  _$UserPreferenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preferredTemperature = null,
    Object? preferredColors = null,
    Object? preferredStyles = null,
    Object? preferredBrands = null,
    Object? excludedItems = null,
    Object? prefersNaturalMaterials = null,
    Object? prefersSyntheticMaterials = null,
    Object? sensitiveToCold = null,
    Object? sensitiveToHeat = null,
    Object? occasionsOfInterest = null,
    Object? maxBudget = freezed,
    Object? fitPreference = freezed,
  }) {
    return _then(_value.copyWith(
      preferredTemperature: null == preferredTemperature
          ? _value.preferredTemperature
          : preferredTemperature // ignore: cast_nullable_to_non_nullable
              as String,
      preferredColors: null == preferredColors
          ? _value.preferredColors
          : preferredColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredStyles: null == preferredStyles
          ? _value.preferredStyles
          : preferredStyles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredBrands: null == preferredBrands
          ? _value.preferredBrands
          : preferredBrands // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedItems: null == excludedItems
          ? _value.excludedItems
          : excludedItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      prefersNaturalMaterials: null == prefersNaturalMaterials
          ? _value.prefersNaturalMaterials
          : prefersNaturalMaterials // ignore: cast_nullable_to_non_nullable
              as bool,
      prefersSyntheticMaterials: null == prefersSyntheticMaterials
          ? _value.prefersSyntheticMaterials
          : prefersSyntheticMaterials // ignore: cast_nullable_to_non_nullable
              as bool,
      sensitiveToCold: null == sensitiveToCold
          ? _value.sensitiveToCold
          : sensitiveToCold // ignore: cast_nullable_to_non_nullable
              as bool,
      sensitiveToHeat: null == sensitiveToHeat
          ? _value.sensitiveToHeat
          : sensitiveToHeat // ignore: cast_nullable_to_non_nullable
              as bool,
      occasionsOfInterest: null == occasionsOfInterest
          ? _value.occasionsOfInterest
          : occasionsOfInterest // ignore: cast_nullable_to_non_nullable
              as List<String>,
      maxBudget: freezed == maxBudget
          ? _value.maxBudget
          : maxBudget // ignore: cast_nullable_to_non_nullable
              as double?,
      fitPreference: freezed == fitPreference
          ? _value.fitPreference
          : fitPreference // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferenceImplCopyWith<$Res>
    implements $UserPreferenceCopyWith<$Res> {
  factory _$$UserPreferenceImplCopyWith(_$UserPreferenceImpl value,
          $Res Function(_$UserPreferenceImpl) then) =
      __$$UserPreferenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'preferred_temperature') String preferredTemperature,
      @JsonKey(name: 'preferred_colors') List<String> preferredColors,
      @JsonKey(name: 'preferred_styles') List<String> preferredStyles,
      @JsonKey(name: 'preferred_brands') List<String> preferredBrands,
      @JsonKey(name: 'excluded_items') List<String> excludedItems,
      @JsonKey(name: 'prefers_natural_materials') bool prefersNaturalMaterials,
      @JsonKey(name: 'prefers_synthetic_materials')
      bool prefersSyntheticMaterials,
      @JsonKey(name: 'sensitive_to_cold') bool sensitiveToCold,
      @JsonKey(name: 'sensitive_to_heat') bool sensitiveToHeat,
      @JsonKey(name: 'occasions_of_interest') List<String> occasionsOfInterest,
      @JsonKey(name: 'max_budget') double? maxBudget,
      @JsonKey(name: 'fit_preference') String? fitPreference});
}

/// @nodoc
class __$$UserPreferenceImplCopyWithImpl<$Res>
    extends _$UserPreferenceCopyWithImpl<$Res, _$UserPreferenceImpl>
    implements _$$UserPreferenceImplCopyWith<$Res> {
  __$$UserPreferenceImplCopyWithImpl(
      _$UserPreferenceImpl _value, $Res Function(_$UserPreferenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? preferredTemperature = null,
    Object? preferredColors = null,
    Object? preferredStyles = null,
    Object? preferredBrands = null,
    Object? excludedItems = null,
    Object? prefersNaturalMaterials = null,
    Object? prefersSyntheticMaterials = null,
    Object? sensitiveToCold = null,
    Object? sensitiveToHeat = null,
    Object? occasionsOfInterest = null,
    Object? maxBudget = freezed,
    Object? fitPreference = freezed,
  }) {
    return _then(_$UserPreferenceImpl(
      preferredTemperature: null == preferredTemperature
          ? _value.preferredTemperature
          : preferredTemperature // ignore: cast_nullable_to_non_nullable
              as String,
      preferredColors: null == preferredColors
          ? _value._preferredColors
          : preferredColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredStyles: null == preferredStyles
          ? _value._preferredStyles
          : preferredStyles // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredBrands: null == preferredBrands
          ? _value._preferredBrands
          : preferredBrands // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedItems: null == excludedItems
          ? _value._excludedItems
          : excludedItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      prefersNaturalMaterials: null == prefersNaturalMaterials
          ? _value.prefersNaturalMaterials
          : prefersNaturalMaterials // ignore: cast_nullable_to_non_nullable
              as bool,
      prefersSyntheticMaterials: null == prefersSyntheticMaterials
          ? _value.prefersSyntheticMaterials
          : prefersSyntheticMaterials // ignore: cast_nullable_to_non_nullable
              as bool,
      sensitiveToCold: null == sensitiveToCold
          ? _value.sensitiveToCold
          : sensitiveToCold // ignore: cast_nullable_to_non_nullable
              as bool,
      sensitiveToHeat: null == sensitiveToHeat
          ? _value.sensitiveToHeat
          : sensitiveToHeat // ignore: cast_nullable_to_non_nullable
              as bool,
      occasionsOfInterest: null == occasionsOfInterest
          ? _value._occasionsOfInterest
          : occasionsOfInterest // ignore: cast_nullable_to_non_nullable
              as List<String>,
      maxBudget: freezed == maxBudget
          ? _value.maxBudget
          : maxBudget // ignore: cast_nullable_to_non_nullable
              as double?,
      fitPreference: freezed == fitPreference
          ? _value.fitPreference
          : fitPreference // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferenceImpl implements _UserPreference {
  const _$UserPreferenceImpl(
      {@JsonKey(name: 'preferred_temperature')
      this.preferredTemperature = 'comfortable',
      @JsonKey(name: 'preferred_colors')
      final List<String> preferredColors = const [],
      @JsonKey(name: 'preferred_styles')
      final List<String> preferredStyles = const [],
      @JsonKey(name: 'preferred_brands')
      final List<String> preferredBrands = const [],
      @JsonKey(name: 'excluded_items')
      final List<String> excludedItems = const [],
      @JsonKey(name: 'prefers_natural_materials')
      this.prefersNaturalMaterials = false,
      @JsonKey(name: 'prefers_synthetic_materials')
      this.prefersSyntheticMaterials = false,
      @JsonKey(name: 'sensitive_to_cold') this.sensitiveToCold = false,
      @JsonKey(name: 'sensitive_to_heat') this.sensitiveToHeat = false,
      @JsonKey(name: 'occasions_of_interest')
      final List<String> occasionsOfInterest = const [],
      @JsonKey(name: 'max_budget') this.maxBudget,
      @JsonKey(name: 'fit_preference') this.fitPreference})
      : _preferredColors = preferredColors,
        _preferredStyles = preferredStyles,
        _preferredBrands = preferredBrands,
        _excludedItems = excludedItems,
        _occasionsOfInterest = occasionsOfInterest;

  factory _$UserPreferenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferenceImplFromJson(json);

  @override
  @JsonKey(name: 'preferred_temperature')
  final String preferredTemperature;
  final List<String> _preferredColors;
  @override
  @JsonKey(name: 'preferred_colors')
  List<String> get preferredColors {
    if (_preferredColors is EqualUnmodifiableListView) return _preferredColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredColors);
  }

  final List<String> _preferredStyles;
  @override
  @JsonKey(name: 'preferred_styles')
  List<String> get preferredStyles {
    if (_preferredStyles is EqualUnmodifiableListView) return _preferredStyles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredStyles);
  }

  final List<String> _preferredBrands;
  @override
  @JsonKey(name: 'preferred_brands')
  List<String> get preferredBrands {
    if (_preferredBrands is EqualUnmodifiableListView) return _preferredBrands;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredBrands);
  }

  final List<String> _excludedItems;
  @override
  @JsonKey(name: 'excluded_items')
  List<String> get excludedItems {
    if (_excludedItems is EqualUnmodifiableListView) return _excludedItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedItems);
  }

  @override
  @JsonKey(name: 'prefers_natural_materials')
  final bool prefersNaturalMaterials;
  @override
  @JsonKey(name: 'prefers_synthetic_materials')
  final bool prefersSyntheticMaterials;
  @override
  @JsonKey(name: 'sensitive_to_cold')
  final bool sensitiveToCold;
  @override
  @JsonKey(name: 'sensitive_to_heat')
  final bool sensitiveToHeat;
  final List<String> _occasionsOfInterest;
  @override
  @JsonKey(name: 'occasions_of_interest')
  List<String> get occasionsOfInterest {
    if (_occasionsOfInterest is EqualUnmodifiableListView)
      return _occasionsOfInterest;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_occasionsOfInterest);
  }

// Недостающие поля
  @override
  @JsonKey(name: 'max_budget')
  final double? maxBudget;
  @override
  @JsonKey(name: 'fit_preference')
  final String? fitPreference;

  @override
  String toString() {
    return 'UserPreference(preferredTemperature: $preferredTemperature, preferredColors: $preferredColors, preferredStyles: $preferredStyles, preferredBrands: $preferredBrands, excludedItems: $excludedItems, prefersNaturalMaterials: $prefersNaturalMaterials, prefersSyntheticMaterials: $prefersSyntheticMaterials, sensitiveToCold: $sensitiveToCold, sensitiveToHeat: $sensitiveToHeat, occasionsOfInterest: $occasionsOfInterest, maxBudget: $maxBudget, fitPreference: $fitPreference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferenceImpl &&
            (identical(other.preferredTemperature, preferredTemperature) ||
                other.preferredTemperature == preferredTemperature) &&
            const DeepCollectionEquality()
                .equals(other._preferredColors, _preferredColors) &&
            const DeepCollectionEquality()
                .equals(other._preferredStyles, _preferredStyles) &&
            const DeepCollectionEquality()
                .equals(other._preferredBrands, _preferredBrands) &&
            const DeepCollectionEquality()
                .equals(other._excludedItems, _excludedItems) &&
            (identical(
                    other.prefersNaturalMaterials, prefersNaturalMaterials) ||
                other.prefersNaturalMaterials == prefersNaturalMaterials) &&
            (identical(other.prefersSyntheticMaterials,
                    prefersSyntheticMaterials) ||
                other.prefersSyntheticMaterials == prefersSyntheticMaterials) &&
            (identical(other.sensitiveToCold, sensitiveToCold) ||
                other.sensitiveToCold == sensitiveToCold) &&
            (identical(other.sensitiveToHeat, sensitiveToHeat) ||
                other.sensitiveToHeat == sensitiveToHeat) &&
            const DeepCollectionEquality()
                .equals(other._occasionsOfInterest, _occasionsOfInterest) &&
            (identical(other.maxBudget, maxBudget) ||
                other.maxBudget == maxBudget) &&
            (identical(other.fitPreference, fitPreference) ||
                other.fitPreference == fitPreference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      preferredTemperature,
      const DeepCollectionEquality().hash(_preferredColors),
      const DeepCollectionEquality().hash(_preferredStyles),
      const DeepCollectionEquality().hash(_preferredBrands),
      const DeepCollectionEquality().hash(_excludedItems),
      prefersNaturalMaterials,
      prefersSyntheticMaterials,
      sensitiveToCold,
      sensitiveToHeat,
      const DeepCollectionEquality().hash(_occasionsOfInterest),
      maxBudget,
      fitPreference);

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferenceImplCopyWith<_$UserPreferenceImpl> get copyWith =>
      __$$UserPreferenceImplCopyWithImpl<_$UserPreferenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferenceImplToJson(
      this,
    );
  }
}

abstract class _UserPreference implements UserPreference {
  const factory _UserPreference(
          {@JsonKey(name: 'preferred_temperature')
          final String preferredTemperature,
          @JsonKey(name: 'preferred_colors') final List<String> preferredColors,
          @JsonKey(name: 'preferred_styles') final List<String> preferredStyles,
          @JsonKey(name: 'preferred_brands') final List<String> preferredBrands,
          @JsonKey(name: 'excluded_items') final List<String> excludedItems,
          @JsonKey(name: 'prefers_natural_materials')
          final bool prefersNaturalMaterials,
          @JsonKey(name: 'prefers_synthetic_materials')
          final bool prefersSyntheticMaterials,
          @JsonKey(name: 'sensitive_to_cold') final bool sensitiveToCold,
          @JsonKey(name: 'sensitive_to_heat') final bool sensitiveToHeat,
          @JsonKey(name: 'occasions_of_interest')
          final List<String> occasionsOfInterest,
          @JsonKey(name: 'max_budget') final double? maxBudget,
          @JsonKey(name: 'fit_preference') final String? fitPreference}) =
      _$UserPreferenceImpl;

  factory _UserPreference.fromJson(Map<String, dynamic> json) =
      _$UserPreferenceImpl.fromJson;

  @override
  @JsonKey(name: 'preferred_temperature')
  String get preferredTemperature;
  @override
  @JsonKey(name: 'preferred_colors')
  List<String> get preferredColors;
  @override
  @JsonKey(name: 'preferred_styles')
  List<String> get preferredStyles;
  @override
  @JsonKey(name: 'preferred_brands')
  List<String> get preferredBrands;
  @override
  @JsonKey(name: 'excluded_items')
  List<String> get excludedItems;
  @override
  @JsonKey(name: 'prefers_natural_materials')
  bool get prefersNaturalMaterials;
  @override
  @JsonKey(name: 'prefers_synthetic_materials')
  bool get prefersSyntheticMaterials;
  @override
  @JsonKey(name: 'sensitive_to_cold')
  bool get sensitiveToCold;
  @override
  @JsonKey(name: 'sensitive_to_heat')
  bool get sensitiveToHeat;
  @override
  @JsonKey(name: 'occasions_of_interest')
  List<String> get occasionsOfInterest; // Недостающие поля
  @override
  @JsonKey(name: 'max_budget')
  double? get maxBudget;
  @override
  @JsonKey(name: 'fit_preference')
  String? get fitPreference;

  /// Create a copy of UserPreference
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferenceImplCopyWith<_$UserPreferenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
