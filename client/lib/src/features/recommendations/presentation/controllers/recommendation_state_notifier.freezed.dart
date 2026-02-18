// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecommendationState {

 AsyncValue<List<Recommendation>> get recommendations; List<Recommendation> get historyRecommendations; List<Recommendation> get savedRecommendations; UserPreference get preferences; bool get isLoading; bool get isRefreshing; String? get error;
/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationStateCopyWith<RecommendationState> get copyWith => _$RecommendationStateCopyWithImpl<RecommendationState>(this as RecommendationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationState&&(identical(other.recommendations, recommendations) || other.recommendations == recommendations)&&const DeepCollectionEquality().equals(other.historyRecommendations, historyRecommendations)&&const DeepCollectionEquality().equals(other.savedRecommendations, savedRecommendations)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,recommendations,const DeepCollectionEquality().hash(historyRecommendations),const DeepCollectionEquality().hash(savedRecommendations),preferences,isLoading,isRefreshing,error);

@override
String toString() {
  return 'RecommendationState(recommendations: $recommendations, historyRecommendations: $historyRecommendations, savedRecommendations: $savedRecommendations, preferences: $preferences, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error)';
}


}

/// @nodoc
abstract mixin class $RecommendationStateCopyWith<$Res>  {
  factory $RecommendationStateCopyWith(RecommendationState value, $Res Function(RecommendationState) _then) = _$RecommendationStateCopyWithImpl;
@useResult
$Res call({
 AsyncValue<List<Recommendation>> recommendations, List<Recommendation> historyRecommendations, List<Recommendation> savedRecommendations, UserPreference preferences, bool isLoading, bool isRefreshing, String? error
});


$UserPreferenceCopyWith<$Res> get preferences;

}
/// @nodoc
class _$RecommendationStateCopyWithImpl<$Res>
    implements $RecommendationStateCopyWith<$Res> {
  _$RecommendationStateCopyWithImpl(this._self, this._then);

  final RecommendationState _self;
  final $Res Function(RecommendationState) _then;

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recommendations = null,Object? historyRecommendations = null,Object? savedRecommendations = null,Object? preferences = null,Object? isLoading = null,Object? isRefreshing = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<Recommendation>>,historyRecommendations: null == historyRecommendations ? _self.historyRecommendations : historyRecommendations // ignore: cast_nullable_to_non_nullable
as List<Recommendation>,savedRecommendations: null == savedRecommendations ? _self.savedRecommendations : savedRecommendations // ignore: cast_nullable_to_non_nullable
as List<Recommendation>,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreference,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferenceCopyWith<$Res> get preferences {
  
  return $UserPreferenceCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [RecommendationState].
extension RecommendationStatePatterns on RecommendationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationState value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationState value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AsyncValue<List<Recommendation>> recommendations,  List<Recommendation> historyRecommendations,  List<Recommendation> savedRecommendations,  UserPreference preferences,  bool isLoading,  bool isRefreshing,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
return $default(_that.recommendations,_that.historyRecommendations,_that.savedRecommendations,_that.preferences,_that.isLoading,_that.isRefreshing,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AsyncValue<List<Recommendation>> recommendations,  List<Recommendation> historyRecommendations,  List<Recommendation> savedRecommendations,  UserPreference preferences,  bool isLoading,  bool isRefreshing,  String? error)  $default,) {final _that = this;
switch (_that) {
case _RecommendationState():
return $default(_that.recommendations,_that.historyRecommendations,_that.savedRecommendations,_that.preferences,_that.isLoading,_that.isRefreshing,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AsyncValue<List<Recommendation>> recommendations,  List<Recommendation> historyRecommendations,  List<Recommendation> savedRecommendations,  UserPreference preferences,  bool isLoading,  bool isRefreshing,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationState() when $default != null:
return $default(_that.recommendations,_that.historyRecommendations,_that.savedRecommendations,_that.preferences,_that.isLoading,_that.isRefreshing,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendationState extends RecommendationState {
  const _RecommendationState({this.recommendations = const AsyncValue.loading(), final  List<Recommendation> historyRecommendations = const [], final  List<Recommendation> savedRecommendations = const [], this.preferences = const UserPreference(), this.isLoading = false, this.isRefreshing = false, this.error}): _historyRecommendations = historyRecommendations,_savedRecommendations = savedRecommendations,super._();
  

@override@JsonKey() final  AsyncValue<List<Recommendation>> recommendations;
 final  List<Recommendation> _historyRecommendations;
@override@JsonKey() List<Recommendation> get historyRecommendations {
  if (_historyRecommendations is EqualUnmodifiableListView) return _historyRecommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_historyRecommendations);
}

 final  List<Recommendation> _savedRecommendations;
@override@JsonKey() List<Recommendation> get savedRecommendations {
  if (_savedRecommendations is EqualUnmodifiableListView) return _savedRecommendations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedRecommendations);
}

@override@JsonKey() final  UserPreference preferences;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isRefreshing;
@override final  String? error;

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationStateCopyWith<_RecommendationState> get copyWith => __$RecommendationStateCopyWithImpl<_RecommendationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationState&&(identical(other.recommendations, recommendations) || other.recommendations == recommendations)&&const DeepCollectionEquality().equals(other._historyRecommendations, _historyRecommendations)&&const DeepCollectionEquality().equals(other._savedRecommendations, _savedRecommendations)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isRefreshing, isRefreshing) || other.isRefreshing == isRefreshing)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,recommendations,const DeepCollectionEquality().hash(_historyRecommendations),const DeepCollectionEquality().hash(_savedRecommendations),preferences,isLoading,isRefreshing,error);

@override
String toString() {
  return 'RecommendationState(recommendations: $recommendations, historyRecommendations: $historyRecommendations, savedRecommendations: $savedRecommendations, preferences: $preferences, isLoading: $isLoading, isRefreshing: $isRefreshing, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RecommendationStateCopyWith<$Res> implements $RecommendationStateCopyWith<$Res> {
  factory _$RecommendationStateCopyWith(_RecommendationState value, $Res Function(_RecommendationState) _then) = __$RecommendationStateCopyWithImpl;
@override @useResult
$Res call({
 AsyncValue<List<Recommendation>> recommendations, List<Recommendation> historyRecommendations, List<Recommendation> savedRecommendations, UserPreference preferences, bool isLoading, bool isRefreshing, String? error
});


@override $UserPreferenceCopyWith<$Res> get preferences;

}
/// @nodoc
class __$RecommendationStateCopyWithImpl<$Res>
    implements _$RecommendationStateCopyWith<$Res> {
  __$RecommendationStateCopyWithImpl(this._self, this._then);

  final _RecommendationState _self;
  final $Res Function(_RecommendationState) _then;

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recommendations = null,Object? historyRecommendations = null,Object? savedRecommendations = null,Object? preferences = null,Object? isLoading = null,Object? isRefreshing = null,Object? error = freezed,}) {
  return _then(_RecommendationState(
recommendations: null == recommendations ? _self.recommendations : recommendations // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<Recommendation>>,historyRecommendations: null == historyRecommendations ? _self._historyRecommendations : historyRecommendations // ignore: cast_nullable_to_non_nullable
as List<Recommendation>,savedRecommendations: null == savedRecommendations ? _self._savedRecommendations : savedRecommendations // ignore: cast_nullable_to_non_nullable
as List<Recommendation>,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreference,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isRefreshing: null == isRefreshing ? _self.isRefreshing : isRefreshing // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RecommendationState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferenceCopyWith<$Res> get preferences {
  
  return $UserPreferenceCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}

// dart format on
