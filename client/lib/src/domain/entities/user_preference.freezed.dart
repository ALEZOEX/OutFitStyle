// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preference.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserPreference {

@JsonKey(name: 'preferred_temperature') String get preferredTemperature;@JsonKey(name: 'preferred_colors') List<String> get preferredColors;@JsonKey(name: 'preferred_styles') List<String> get preferredStyles;@JsonKey(name: 'preferred_brands') List<String> get preferredBrands;@JsonKey(name: 'excluded_items') List<String> get excludedItems;@JsonKey(name: 'prefers_natural_materials') bool get prefersNaturalMaterials;@JsonKey(name: 'prefers_synthetic_materials') bool get prefersSyntheticMaterials;@JsonKey(name: 'sensitive_to_cold') bool get sensitiveToCold;@JsonKey(name: 'sensitive_to_heat') bool get sensitiveToHeat;@JsonKey(name: 'occasions_of_interest') List<String> get occasionsOfInterest;// Недостающие поля
@JsonKey(name: 'max_budget') double? get maxBudget;@JsonKey(name: 'fit_preference') String? get fitPreference;
/// Create a copy of UserPreference
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPreferenceCopyWith<UserPreference> get copyWith => _$UserPreferenceCopyWithImpl<UserPreference>(this as UserPreference, _$identity);

  /// Serializes this UserPreference to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPreference&&(identical(other.preferredTemperature, preferredTemperature) || other.preferredTemperature == preferredTemperature)&&const DeepCollectionEquality().equals(other.preferredColors, preferredColors)&&const DeepCollectionEquality().equals(other.preferredStyles, preferredStyles)&&const DeepCollectionEquality().equals(other.preferredBrands, preferredBrands)&&const DeepCollectionEquality().equals(other.excludedItems, excludedItems)&&(identical(other.prefersNaturalMaterials, prefersNaturalMaterials) || other.prefersNaturalMaterials == prefersNaturalMaterials)&&(identical(other.prefersSyntheticMaterials, prefersSyntheticMaterials) || other.prefersSyntheticMaterials == prefersSyntheticMaterials)&&(identical(other.sensitiveToCold, sensitiveToCold) || other.sensitiveToCold == sensitiveToCold)&&(identical(other.sensitiveToHeat, sensitiveToHeat) || other.sensitiveToHeat == sensitiveToHeat)&&const DeepCollectionEquality().equals(other.occasionsOfInterest, occasionsOfInterest)&&(identical(other.maxBudget, maxBudget) || other.maxBudget == maxBudget)&&(identical(other.fitPreference, fitPreference) || other.fitPreference == fitPreference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preferredTemperature,const DeepCollectionEquality().hash(preferredColors),const DeepCollectionEquality().hash(preferredStyles),const DeepCollectionEquality().hash(preferredBrands),const DeepCollectionEquality().hash(excludedItems),prefersNaturalMaterials,prefersSyntheticMaterials,sensitiveToCold,sensitiveToHeat,const DeepCollectionEquality().hash(occasionsOfInterest),maxBudget,fitPreference);

@override
String toString() {
  return 'UserPreference(preferredTemperature: $preferredTemperature, preferredColors: $preferredColors, preferredStyles: $preferredStyles, preferredBrands: $preferredBrands, excludedItems: $excludedItems, prefersNaturalMaterials: $prefersNaturalMaterials, prefersSyntheticMaterials: $prefersSyntheticMaterials, sensitiveToCold: $sensitiveToCold, sensitiveToHeat: $sensitiveToHeat, occasionsOfInterest: $occasionsOfInterest, maxBudget: $maxBudget, fitPreference: $fitPreference)';
}


}

/// @nodoc
abstract mixin class $UserPreferenceCopyWith<$Res>  {
  factory $UserPreferenceCopyWith(UserPreference value, $Res Function(UserPreference) _then) = _$UserPreferenceCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'preferred_temperature') String preferredTemperature,@JsonKey(name: 'preferred_colors') List<String> preferredColors,@JsonKey(name: 'preferred_styles') List<String> preferredStyles,@JsonKey(name: 'preferred_brands') List<String> preferredBrands,@JsonKey(name: 'excluded_items') List<String> excludedItems,@JsonKey(name: 'prefers_natural_materials') bool prefersNaturalMaterials,@JsonKey(name: 'prefers_synthetic_materials') bool prefersSyntheticMaterials,@JsonKey(name: 'sensitive_to_cold') bool sensitiveToCold,@JsonKey(name: 'sensitive_to_heat') bool sensitiveToHeat,@JsonKey(name: 'occasions_of_interest') List<String> occasionsOfInterest,@JsonKey(name: 'max_budget') double? maxBudget,@JsonKey(name: 'fit_preference') String? fitPreference
});




}
/// @nodoc
class _$UserPreferenceCopyWithImpl<$Res>
    implements $UserPreferenceCopyWith<$Res> {
  _$UserPreferenceCopyWithImpl(this._self, this._then);

  final UserPreference _self;
  final $Res Function(UserPreference) _then;

/// Create a copy of UserPreference
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preferredTemperature = null,Object? preferredColors = null,Object? preferredStyles = null,Object? preferredBrands = null,Object? excludedItems = null,Object? prefersNaturalMaterials = null,Object? prefersSyntheticMaterials = null,Object? sensitiveToCold = null,Object? sensitiveToHeat = null,Object? occasionsOfInterest = null,Object? maxBudget = freezed,Object? fitPreference = freezed,}) {
  return _then(_self.copyWith(
preferredTemperature: null == preferredTemperature ? _self.preferredTemperature : preferredTemperature // ignore: cast_nullable_to_non_nullable
as String,preferredColors: null == preferredColors ? _self.preferredColors : preferredColors // ignore: cast_nullable_to_non_nullable
as List<String>,preferredStyles: null == preferredStyles ? _self.preferredStyles : preferredStyles // ignore: cast_nullable_to_non_nullable
as List<String>,preferredBrands: null == preferredBrands ? _self.preferredBrands : preferredBrands // ignore: cast_nullable_to_non_nullable
as List<String>,excludedItems: null == excludedItems ? _self.excludedItems : excludedItems // ignore: cast_nullable_to_non_nullable
as List<String>,prefersNaturalMaterials: null == prefersNaturalMaterials ? _self.prefersNaturalMaterials : prefersNaturalMaterials // ignore: cast_nullable_to_non_nullable
as bool,prefersSyntheticMaterials: null == prefersSyntheticMaterials ? _self.prefersSyntheticMaterials : prefersSyntheticMaterials // ignore: cast_nullable_to_non_nullable
as bool,sensitiveToCold: null == sensitiveToCold ? _self.sensitiveToCold : sensitiveToCold // ignore: cast_nullable_to_non_nullable
as bool,sensitiveToHeat: null == sensitiveToHeat ? _self.sensitiveToHeat : sensitiveToHeat // ignore: cast_nullable_to_non_nullable
as bool,occasionsOfInterest: null == occasionsOfInterest ? _self.occasionsOfInterest : occasionsOfInterest // ignore: cast_nullable_to_non_nullable
as List<String>,maxBudget: freezed == maxBudget ? _self.maxBudget : maxBudget // ignore: cast_nullable_to_non_nullable
as double?,fitPreference: freezed == fitPreference ? _self.fitPreference : fitPreference // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPreference].
extension UserPreferencePatterns on UserPreference {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPreference value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPreference() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPreference value)  $default,){
final _that = this;
switch (_that) {
case _UserPreference():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPreference value)?  $default,){
final _that = this;
switch (_that) {
case _UserPreference() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'preferred_temperature')  String preferredTemperature, @JsonKey(name: 'preferred_colors')  List<String> preferredColors, @JsonKey(name: 'preferred_styles')  List<String> preferredStyles, @JsonKey(name: 'preferred_brands')  List<String> preferredBrands, @JsonKey(name: 'excluded_items')  List<String> excludedItems, @JsonKey(name: 'prefers_natural_materials')  bool prefersNaturalMaterials, @JsonKey(name: 'prefers_synthetic_materials')  bool prefersSyntheticMaterials, @JsonKey(name: 'sensitive_to_cold')  bool sensitiveToCold, @JsonKey(name: 'sensitive_to_heat')  bool sensitiveToHeat, @JsonKey(name: 'occasions_of_interest')  List<String> occasionsOfInterest, @JsonKey(name: 'max_budget')  double? maxBudget, @JsonKey(name: 'fit_preference')  String? fitPreference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPreference() when $default != null:
return $default(_that.preferredTemperature,_that.preferredColors,_that.preferredStyles,_that.preferredBrands,_that.excludedItems,_that.prefersNaturalMaterials,_that.prefersSyntheticMaterials,_that.sensitiveToCold,_that.sensitiveToHeat,_that.occasionsOfInterest,_that.maxBudget,_that.fitPreference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'preferred_temperature')  String preferredTemperature, @JsonKey(name: 'preferred_colors')  List<String> preferredColors, @JsonKey(name: 'preferred_styles')  List<String> preferredStyles, @JsonKey(name: 'preferred_brands')  List<String> preferredBrands, @JsonKey(name: 'excluded_items')  List<String> excludedItems, @JsonKey(name: 'prefers_natural_materials')  bool prefersNaturalMaterials, @JsonKey(name: 'prefers_synthetic_materials')  bool prefersSyntheticMaterials, @JsonKey(name: 'sensitive_to_cold')  bool sensitiveToCold, @JsonKey(name: 'sensitive_to_heat')  bool sensitiveToHeat, @JsonKey(name: 'occasions_of_interest')  List<String> occasionsOfInterest, @JsonKey(name: 'max_budget')  double? maxBudget, @JsonKey(name: 'fit_preference')  String? fitPreference)  $default,) {final _that = this;
switch (_that) {
case _UserPreference():
return $default(_that.preferredTemperature,_that.preferredColors,_that.preferredStyles,_that.preferredBrands,_that.excludedItems,_that.prefersNaturalMaterials,_that.prefersSyntheticMaterials,_that.sensitiveToCold,_that.sensitiveToHeat,_that.occasionsOfInterest,_that.maxBudget,_that.fitPreference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'preferred_temperature')  String preferredTemperature, @JsonKey(name: 'preferred_colors')  List<String> preferredColors, @JsonKey(name: 'preferred_styles')  List<String> preferredStyles, @JsonKey(name: 'preferred_brands')  List<String> preferredBrands, @JsonKey(name: 'excluded_items')  List<String> excludedItems, @JsonKey(name: 'prefers_natural_materials')  bool prefersNaturalMaterials, @JsonKey(name: 'prefers_synthetic_materials')  bool prefersSyntheticMaterials, @JsonKey(name: 'sensitive_to_cold')  bool sensitiveToCold, @JsonKey(name: 'sensitive_to_heat')  bool sensitiveToHeat, @JsonKey(name: 'occasions_of_interest')  List<String> occasionsOfInterest, @JsonKey(name: 'max_budget')  double? maxBudget, @JsonKey(name: 'fit_preference')  String? fitPreference)?  $default,) {final _that = this;
switch (_that) {
case _UserPreference() when $default != null:
return $default(_that.preferredTemperature,_that.preferredColors,_that.preferredStyles,_that.preferredBrands,_that.excludedItems,_that.prefersNaturalMaterials,_that.prefersSyntheticMaterials,_that.sensitiveToCold,_that.sensitiveToHeat,_that.occasionsOfInterest,_that.maxBudget,_that.fitPreference);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserPreference implements UserPreference {
  const _UserPreference({@JsonKey(name: 'preferred_temperature') this.preferredTemperature = 'comfortable', @JsonKey(name: 'preferred_colors') final  List<String> preferredColors = const [], @JsonKey(name: 'preferred_styles') final  List<String> preferredStyles = const [], @JsonKey(name: 'preferred_brands') final  List<String> preferredBrands = const [], @JsonKey(name: 'excluded_items') final  List<String> excludedItems = const [], @JsonKey(name: 'prefers_natural_materials') this.prefersNaturalMaterials = false, @JsonKey(name: 'prefers_synthetic_materials') this.prefersSyntheticMaterials = false, @JsonKey(name: 'sensitive_to_cold') this.sensitiveToCold = false, @JsonKey(name: 'sensitive_to_heat') this.sensitiveToHeat = false, @JsonKey(name: 'occasions_of_interest') final  List<String> occasionsOfInterest = const [], @JsonKey(name: 'max_budget') this.maxBudget, @JsonKey(name: 'fit_preference') this.fitPreference}): _preferredColors = preferredColors,_preferredStyles = preferredStyles,_preferredBrands = preferredBrands,_excludedItems = excludedItems,_occasionsOfInterest = occasionsOfInterest;
  factory _UserPreference.fromJson(Map<String, dynamic> json) => _$UserPreferenceFromJson(json);

@override@JsonKey(name: 'preferred_temperature') final  String preferredTemperature;
 final  List<String> _preferredColors;
@override@JsonKey(name: 'preferred_colors') List<String> get preferredColors {
  if (_preferredColors is EqualUnmodifiableListView) return _preferredColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredColors);
}

 final  List<String> _preferredStyles;
@override@JsonKey(name: 'preferred_styles') List<String> get preferredStyles {
  if (_preferredStyles is EqualUnmodifiableListView) return _preferredStyles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredStyles);
}

 final  List<String> _preferredBrands;
@override@JsonKey(name: 'preferred_brands') List<String> get preferredBrands {
  if (_preferredBrands is EqualUnmodifiableListView) return _preferredBrands;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredBrands);
}

 final  List<String> _excludedItems;
@override@JsonKey(name: 'excluded_items') List<String> get excludedItems {
  if (_excludedItems is EqualUnmodifiableListView) return _excludedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedItems);
}

@override@JsonKey(name: 'prefers_natural_materials') final  bool prefersNaturalMaterials;
@override@JsonKey(name: 'prefers_synthetic_materials') final  bool prefersSyntheticMaterials;
@override@JsonKey(name: 'sensitive_to_cold') final  bool sensitiveToCold;
@override@JsonKey(name: 'sensitive_to_heat') final  bool sensitiveToHeat;
 final  List<String> _occasionsOfInterest;
@override@JsonKey(name: 'occasions_of_interest') List<String> get occasionsOfInterest {
  if (_occasionsOfInterest is EqualUnmodifiableListView) return _occasionsOfInterest;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_occasionsOfInterest);
}

// Недостающие поля
@override@JsonKey(name: 'max_budget') final  double? maxBudget;
@override@JsonKey(name: 'fit_preference') final  String? fitPreference;

/// Create a copy of UserPreference
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPreferenceCopyWith<_UserPreference> get copyWith => __$UserPreferenceCopyWithImpl<_UserPreference>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserPreferenceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPreference&&(identical(other.preferredTemperature, preferredTemperature) || other.preferredTemperature == preferredTemperature)&&const DeepCollectionEquality().equals(other._preferredColors, _preferredColors)&&const DeepCollectionEquality().equals(other._preferredStyles, _preferredStyles)&&const DeepCollectionEquality().equals(other._preferredBrands, _preferredBrands)&&const DeepCollectionEquality().equals(other._excludedItems, _excludedItems)&&(identical(other.prefersNaturalMaterials, prefersNaturalMaterials) || other.prefersNaturalMaterials == prefersNaturalMaterials)&&(identical(other.prefersSyntheticMaterials, prefersSyntheticMaterials) || other.prefersSyntheticMaterials == prefersSyntheticMaterials)&&(identical(other.sensitiveToCold, sensitiveToCold) || other.sensitiveToCold == sensitiveToCold)&&(identical(other.sensitiveToHeat, sensitiveToHeat) || other.sensitiveToHeat == sensitiveToHeat)&&const DeepCollectionEquality().equals(other._occasionsOfInterest, _occasionsOfInterest)&&(identical(other.maxBudget, maxBudget) || other.maxBudget == maxBudget)&&(identical(other.fitPreference, fitPreference) || other.fitPreference == fitPreference));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preferredTemperature,const DeepCollectionEquality().hash(_preferredColors),const DeepCollectionEquality().hash(_preferredStyles),const DeepCollectionEquality().hash(_preferredBrands),const DeepCollectionEquality().hash(_excludedItems),prefersNaturalMaterials,prefersSyntheticMaterials,sensitiveToCold,sensitiveToHeat,const DeepCollectionEquality().hash(_occasionsOfInterest),maxBudget,fitPreference);

@override
String toString() {
  return 'UserPreference(preferredTemperature: $preferredTemperature, preferredColors: $preferredColors, preferredStyles: $preferredStyles, preferredBrands: $preferredBrands, excludedItems: $excludedItems, prefersNaturalMaterials: $prefersNaturalMaterials, prefersSyntheticMaterials: $prefersSyntheticMaterials, sensitiveToCold: $sensitiveToCold, sensitiveToHeat: $sensitiveToHeat, occasionsOfInterest: $occasionsOfInterest, maxBudget: $maxBudget, fitPreference: $fitPreference)';
}


}

/// @nodoc
abstract mixin class _$UserPreferenceCopyWith<$Res> implements $UserPreferenceCopyWith<$Res> {
  factory _$UserPreferenceCopyWith(_UserPreference value, $Res Function(_UserPreference) _then) = __$UserPreferenceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'preferred_temperature') String preferredTemperature,@JsonKey(name: 'preferred_colors') List<String> preferredColors,@JsonKey(name: 'preferred_styles') List<String> preferredStyles,@JsonKey(name: 'preferred_brands') List<String> preferredBrands,@JsonKey(name: 'excluded_items') List<String> excludedItems,@JsonKey(name: 'prefers_natural_materials') bool prefersNaturalMaterials,@JsonKey(name: 'prefers_synthetic_materials') bool prefersSyntheticMaterials,@JsonKey(name: 'sensitive_to_cold') bool sensitiveToCold,@JsonKey(name: 'sensitive_to_heat') bool sensitiveToHeat,@JsonKey(name: 'occasions_of_interest') List<String> occasionsOfInterest,@JsonKey(name: 'max_budget') double? maxBudget,@JsonKey(name: 'fit_preference') String? fitPreference
});




}
/// @nodoc
class __$UserPreferenceCopyWithImpl<$Res>
    implements _$UserPreferenceCopyWith<$Res> {
  __$UserPreferenceCopyWithImpl(this._self, this._then);

  final _UserPreference _self;
  final $Res Function(_UserPreference) _then;

/// Create a copy of UserPreference
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preferredTemperature = null,Object? preferredColors = null,Object? preferredStyles = null,Object? preferredBrands = null,Object? excludedItems = null,Object? prefersNaturalMaterials = null,Object? prefersSyntheticMaterials = null,Object? sensitiveToCold = null,Object? sensitiveToHeat = null,Object? occasionsOfInterest = null,Object? maxBudget = freezed,Object? fitPreference = freezed,}) {
  return _then(_UserPreference(
preferredTemperature: null == preferredTemperature ? _self.preferredTemperature : preferredTemperature // ignore: cast_nullable_to_non_nullable
as String,preferredColors: null == preferredColors ? _self._preferredColors : preferredColors // ignore: cast_nullable_to_non_nullable
as List<String>,preferredStyles: null == preferredStyles ? _self._preferredStyles : preferredStyles // ignore: cast_nullable_to_non_nullable
as List<String>,preferredBrands: null == preferredBrands ? _self._preferredBrands : preferredBrands // ignore: cast_nullable_to_non_nullable
as List<String>,excludedItems: null == excludedItems ? _self._excludedItems : excludedItems // ignore: cast_nullable_to_non_nullable
as List<String>,prefersNaturalMaterials: null == prefersNaturalMaterials ? _self.prefersNaturalMaterials : prefersNaturalMaterials // ignore: cast_nullable_to_non_nullable
as bool,prefersSyntheticMaterials: null == prefersSyntheticMaterials ? _self.prefersSyntheticMaterials : prefersSyntheticMaterials // ignore: cast_nullable_to_non_nullable
as bool,sensitiveToCold: null == sensitiveToCold ? _self.sensitiveToCold : sensitiveToCold // ignore: cast_nullable_to_non_nullable
as bool,sensitiveToHeat: null == sensitiveToHeat ? _self.sensitiveToHeat : sensitiveToHeat // ignore: cast_nullable_to_non_nullable
as bool,occasionsOfInterest: null == occasionsOfInterest ? _self._occasionsOfInterest : occasionsOfInterest // ignore: cast_nullable_to_non_nullable
as List<String>,maxBudget: freezed == maxBudget ? _self.maxBudget : maxBudget // ignore: cast_nullable_to_non_nullable
as double?,fitPreference: freezed == fitPreference ? _self.fitPreference : fitPreference // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
