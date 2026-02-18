// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 AsyncValue<List<RecommendationRow>> get todayRecommendations; AsyncValue<List<WardrobeItem>> get wardrobeStats; AsyncValue<WeatherEntity?> get currentWeather; AsyncValue<OutfitEntity?> get currentOutfit; bool get isLoading; String? get error;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.todayRecommendations, todayRecommendations) || other.todayRecommendations == todayRecommendations)&&(identical(other.wardrobeStats, wardrobeStats) || other.wardrobeStats == wardrobeStats)&&(identical(other.currentWeather, currentWeather) || other.currentWeather == currentWeather)&&(identical(other.currentOutfit, currentOutfit) || other.currentOutfit == currentOutfit)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,todayRecommendations,wardrobeStats,currentWeather,currentOutfit,isLoading,error);

@override
String toString() {
  return 'HomeState(todayRecommendations: $todayRecommendations, wardrobeStats: $wardrobeStats, currentWeather: $currentWeather, currentOutfit: $currentOutfit, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 AsyncValue<List<RecommendationRow>> todayRecommendations, AsyncValue<List<WardrobeItem>> wardrobeStats, AsyncValue<WeatherEntity?> currentWeather, AsyncValue<OutfitEntity?> currentOutfit, bool isLoading, String? error
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? todayRecommendations = null,Object? wardrobeStats = null,Object? currentWeather = null,Object? currentOutfit = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
todayRecommendations: null == todayRecommendations ? _self.todayRecommendations : todayRecommendations // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<RecommendationRow>>,wardrobeStats: null == wardrobeStats ? _self.wardrobeStats : wardrobeStats // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<WardrobeItem>>,currentWeather: null == currentWeather ? _self.currentWeather : currentWeather // ignore: cast_nullable_to_non_nullable
as AsyncValue<WeatherEntity?>,currentOutfit: null == currentOutfit ? _self.currentOutfit : currentOutfit // ignore: cast_nullable_to_non_nullable
as AsyncValue<OutfitEntity?>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeState value)  $default,){
final _that = this;
switch (_that) {
case _HomeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AsyncValue<List<RecommendationRow>> todayRecommendations,  AsyncValue<List<WardrobeItem>> wardrobeStats,  AsyncValue<WeatherEntity?> currentWeather,  AsyncValue<OutfitEntity?> currentOutfit,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.todayRecommendations,_that.wardrobeStats,_that.currentWeather,_that.currentOutfit,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AsyncValue<List<RecommendationRow>> todayRecommendations,  AsyncValue<List<WardrobeItem>> wardrobeStats,  AsyncValue<WeatherEntity?> currentWeather,  AsyncValue<OutfitEntity?> currentOutfit,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _HomeState():
return $default(_that.todayRecommendations,_that.wardrobeStats,_that.currentWeather,_that.currentOutfit,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AsyncValue<List<RecommendationRow>> todayRecommendations,  AsyncValue<List<WardrobeItem>> wardrobeStats,  AsyncValue<WeatherEntity?> currentWeather,  AsyncValue<OutfitEntity?> currentOutfit,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _HomeState() when $default != null:
return $default(_that.todayRecommendations,_that.wardrobeStats,_that.currentWeather,_that.currentOutfit,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _HomeState extends HomeState {
  const _HomeState({this.todayRecommendations = const AsyncValue.loading(), this.wardrobeStats = const AsyncValue.loading(), this.currentWeather = const AsyncValue.data(null), this.currentOutfit = const AsyncValue.data(null), this.isLoading = false, this.error}): super._();
  

@override@JsonKey() final  AsyncValue<List<RecommendationRow>> todayRecommendations;
@override@JsonKey() final  AsyncValue<List<WardrobeItem>> wardrobeStats;
@override@JsonKey() final  AsyncValue<WeatherEntity?> currentWeather;
@override@JsonKey() final  AsyncValue<OutfitEntity?> currentOutfit;
@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.todayRecommendations, todayRecommendations) || other.todayRecommendations == todayRecommendations)&&(identical(other.wardrobeStats, wardrobeStats) || other.wardrobeStats == wardrobeStats)&&(identical(other.currentWeather, currentWeather) || other.currentWeather == currentWeather)&&(identical(other.currentOutfit, currentOutfit) || other.currentOutfit == currentOutfit)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,todayRecommendations,wardrobeStats,currentWeather,currentOutfit,isLoading,error);

@override
String toString() {
  return 'HomeState(todayRecommendations: $todayRecommendations, wardrobeStats: $wardrobeStats, currentWeather: $currentWeather, currentOutfit: $currentOutfit, isLoading: $isLoading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 AsyncValue<List<RecommendationRow>> todayRecommendations, AsyncValue<List<WardrobeItem>> wardrobeStats, AsyncValue<WeatherEntity?> currentWeather, AsyncValue<OutfitEntity?> currentOutfit, bool isLoading, String? error
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? todayRecommendations = null,Object? wardrobeStats = null,Object? currentWeather = null,Object? currentOutfit = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_HomeState(
todayRecommendations: null == todayRecommendations ? _self.todayRecommendations : todayRecommendations // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<RecommendationRow>>,wardrobeStats: null == wardrobeStats ? _self.wardrobeStats : wardrobeStats // ignore: cast_nullable_to_non_nullable
as AsyncValue<List<WardrobeItem>>,currentWeather: null == currentWeather ? _self.currentWeather : currentWeather // ignore: cast_nullable_to_non_nullable
as AsyncValue<WeatherEntity?>,currentOutfit: null == currentOutfit ? _self.currentOutfit : currentOutfit // ignore: cast_nullable_to_non_nullable
as AsyncValue<OutfitEntity?>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
