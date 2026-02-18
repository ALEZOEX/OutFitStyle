// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'personalized_recommendation_algorithm.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonalizedRecommendationAlgorithm {

 String get id; String get name; String get description; RecommendationAlgorithmType get type; double get accuracy; double get precision; double get recall; double get f1Score; List<String> get featuresUsed; List<String> get weights;// feature weights
 PersonalizationLevel get personalizationLevel; int get trainingSamples; bool get isActive; bool get isDefault; List<String> get tags; String get dummyField;// Workaround for DateTime default issue
 DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PersonalizedRecommendationAlgorithm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonalizedRecommendationAlgorithmCopyWith<PersonalizedRecommendationAlgorithm> get copyWith => _$PersonalizedRecommendationAlgorithmCopyWithImpl<PersonalizedRecommendationAlgorithm>(this as PersonalizedRecommendationAlgorithm, _$identity);

  /// Serializes this PersonalizedRecommendationAlgorithm to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonalizedRecommendationAlgorithm&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.precision, precision) || other.precision == precision)&&(identical(other.recall, recall) || other.recall == recall)&&(identical(other.f1Score, f1Score) || other.f1Score == f1Score)&&const DeepCollectionEquality().equals(other.featuresUsed, featuresUsed)&&const DeepCollectionEquality().equals(other.weights, weights)&&(identical(other.personalizationLevel, personalizationLevel) || other.personalizationLevel == personalizationLevel)&&(identical(other.trainingSamples, trainingSamples) || other.trainingSamples == trainingSamples)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.dummyField, dummyField) || other.dummyField == dummyField)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,accuracy,precision,recall,f1Score,const DeepCollectionEquality().hash(featuresUsed),const DeepCollectionEquality().hash(weights),personalizationLevel,trainingSamples,isActive,isDefault,const DeepCollectionEquality().hash(tags),dummyField,createdAt,updatedAt);

@override
String toString() {
  return 'PersonalizedRecommendationAlgorithm(id: $id, name: $name, description: $description, type: $type, accuracy: $accuracy, precision: $precision, recall: $recall, f1Score: $f1Score, featuresUsed: $featuresUsed, weights: $weights, personalizationLevel: $personalizationLevel, trainingSamples: $trainingSamples, isActive: $isActive, isDefault: $isDefault, tags: $tags, dummyField: $dummyField, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PersonalizedRecommendationAlgorithmCopyWith<$Res>  {
  factory $PersonalizedRecommendationAlgorithmCopyWith(PersonalizedRecommendationAlgorithm value, $Res Function(PersonalizedRecommendationAlgorithm) _then) = _$PersonalizedRecommendationAlgorithmCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, RecommendationAlgorithmType type, double accuracy, double precision, double recall, double f1Score, List<String> featuresUsed, List<String> weights, PersonalizationLevel personalizationLevel, int trainingSamples, bool isActive, bool isDefault, List<String> tags, String dummyField, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PersonalizedRecommendationAlgorithmCopyWithImpl<$Res>
    implements $PersonalizedRecommendationAlgorithmCopyWith<$Res> {
  _$PersonalizedRecommendationAlgorithmCopyWithImpl(this._self, this._then);

  final PersonalizedRecommendationAlgorithm _self;
  final $Res Function(PersonalizedRecommendationAlgorithm) _then;

/// Create a copy of PersonalizedRecommendationAlgorithm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? accuracy = null,Object? precision = null,Object? recall = null,Object? f1Score = null,Object? featuresUsed = null,Object? weights = null,Object? personalizationLevel = null,Object? trainingSamples = null,Object? isActive = null,Object? isDefault = null,Object? tags = null,Object? dummyField = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecommendationAlgorithmType,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,precision: null == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as double,recall: null == recall ? _self.recall : recall // ignore: cast_nullable_to_non_nullable
as double,f1Score: null == f1Score ? _self.f1Score : f1Score // ignore: cast_nullable_to_non_nullable
as double,featuresUsed: null == featuresUsed ? _self.featuresUsed : featuresUsed // ignore: cast_nullable_to_non_nullable
as List<String>,weights: null == weights ? _self.weights : weights // ignore: cast_nullable_to_non_nullable
as List<String>,personalizationLevel: null == personalizationLevel ? _self.personalizationLevel : personalizationLevel // ignore: cast_nullable_to_non_nullable
as PersonalizationLevel,trainingSamples: null == trainingSamples ? _self.trainingSamples : trainingSamples // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,dummyField: null == dummyField ? _self.dummyField : dummyField // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonalizedRecommendationAlgorithm].
extension PersonalizedRecommendationAlgorithmPatterns on PersonalizedRecommendationAlgorithm {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonalizedRecommendationAlgorithm value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonalizedRecommendationAlgorithm() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonalizedRecommendationAlgorithm value)  $default,){
final _that = this;
switch (_that) {
case _PersonalizedRecommendationAlgorithm():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonalizedRecommendationAlgorithm value)?  $default,){
final _that = this;
switch (_that) {
case _PersonalizedRecommendationAlgorithm() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  RecommendationAlgorithmType type,  double accuracy,  double precision,  double recall,  double f1Score,  List<String> featuresUsed,  List<String> weights,  PersonalizationLevel personalizationLevel,  int trainingSamples,  bool isActive,  bool isDefault,  List<String> tags,  String dummyField,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonalizedRecommendationAlgorithm() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.accuracy,_that.precision,_that.recall,_that.f1Score,_that.featuresUsed,_that.weights,_that.personalizationLevel,_that.trainingSamples,_that.isActive,_that.isDefault,_that.tags,_that.dummyField,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  RecommendationAlgorithmType type,  double accuracy,  double precision,  double recall,  double f1Score,  List<String> featuresUsed,  List<String> weights,  PersonalizationLevel personalizationLevel,  int trainingSamples,  bool isActive,  bool isDefault,  List<String> tags,  String dummyField,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PersonalizedRecommendationAlgorithm():
return $default(_that.id,_that.name,_that.description,_that.type,_that.accuracy,_that.precision,_that.recall,_that.f1Score,_that.featuresUsed,_that.weights,_that.personalizationLevel,_that.trainingSamples,_that.isActive,_that.isDefault,_that.tags,_that.dummyField,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  RecommendationAlgorithmType type,  double accuracy,  double precision,  double recall,  double f1Score,  List<String> featuresUsed,  List<String> weights,  PersonalizationLevel personalizationLevel,  int trainingSamples,  bool isActive,  bool isDefault,  List<String> tags,  String dummyField,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PersonalizedRecommendationAlgorithm() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.type,_that.accuracy,_that.precision,_that.recall,_that.f1Score,_that.featuresUsed,_that.weights,_that.personalizationLevel,_that.trainingSamples,_that.isActive,_that.isDefault,_that.tags,_that.dummyField,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PersonalizedRecommendationAlgorithm implements PersonalizedRecommendationAlgorithm {
  const _PersonalizedRecommendationAlgorithm({this.id = '', this.name = '', this.description = '', this.type = RecommendationAlgorithmType.collaborativeFiltering, this.accuracy = 0.0, this.precision = 0.0, this.recall = 0.0, this.f1Score = 0.0, final  List<String> featuresUsed = const <String>[], final  List<String> weights = const <String>[], this.personalizationLevel = PersonalizationLevel.high, this.trainingSamples = 0, this.isActive = false, this.isDefault = false, final  List<String> tags = const <String>[], this.dummyField = '', this.createdAt, this.updatedAt}): _featuresUsed = featuresUsed,_weights = weights,_tags = tags;
  factory _PersonalizedRecommendationAlgorithm.fromJson(Map<String, dynamic> json) => _$PersonalizedRecommendationAlgorithmFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  RecommendationAlgorithmType type;
@override@JsonKey() final  double accuracy;
@override@JsonKey() final  double precision;
@override@JsonKey() final  double recall;
@override@JsonKey() final  double f1Score;
 final  List<String> _featuresUsed;
@override@JsonKey() List<String> get featuresUsed {
  if (_featuresUsed is EqualUnmodifiableListView) return _featuresUsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_featuresUsed);
}

 final  List<String> _weights;
@override@JsonKey() List<String> get weights {
  if (_weights is EqualUnmodifiableListView) return _weights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_weights);
}

// feature weights
@override@JsonKey() final  PersonalizationLevel personalizationLevel;
@override@JsonKey() final  int trainingSamples;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isDefault;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  String dummyField;
// Workaround for DateTime default issue
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PersonalizedRecommendationAlgorithm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonalizedRecommendationAlgorithmCopyWith<_PersonalizedRecommendationAlgorithm> get copyWith => __$PersonalizedRecommendationAlgorithmCopyWithImpl<_PersonalizedRecommendationAlgorithm>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonalizedRecommendationAlgorithmToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonalizedRecommendationAlgorithm&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.precision, precision) || other.precision == precision)&&(identical(other.recall, recall) || other.recall == recall)&&(identical(other.f1Score, f1Score) || other.f1Score == f1Score)&&const DeepCollectionEquality().equals(other._featuresUsed, _featuresUsed)&&const DeepCollectionEquality().equals(other._weights, _weights)&&(identical(other.personalizationLevel, personalizationLevel) || other.personalizationLevel == personalizationLevel)&&(identical(other.trainingSamples, trainingSamples) || other.trainingSamples == trainingSamples)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.dummyField, dummyField) || other.dummyField == dummyField)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,type,accuracy,precision,recall,f1Score,const DeepCollectionEquality().hash(_featuresUsed),const DeepCollectionEquality().hash(_weights),personalizationLevel,trainingSamples,isActive,isDefault,const DeepCollectionEquality().hash(_tags),dummyField,createdAt,updatedAt);

@override
String toString() {
  return 'PersonalizedRecommendationAlgorithm(id: $id, name: $name, description: $description, type: $type, accuracy: $accuracy, precision: $precision, recall: $recall, f1Score: $f1Score, featuresUsed: $featuresUsed, weights: $weights, personalizationLevel: $personalizationLevel, trainingSamples: $trainingSamples, isActive: $isActive, isDefault: $isDefault, tags: $tags, dummyField: $dummyField, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PersonalizedRecommendationAlgorithmCopyWith<$Res> implements $PersonalizedRecommendationAlgorithmCopyWith<$Res> {
  factory _$PersonalizedRecommendationAlgorithmCopyWith(_PersonalizedRecommendationAlgorithm value, $Res Function(_PersonalizedRecommendationAlgorithm) _then) = __$PersonalizedRecommendationAlgorithmCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, RecommendationAlgorithmType type, double accuracy, double precision, double recall, double f1Score, List<String> featuresUsed, List<String> weights, PersonalizationLevel personalizationLevel, int trainingSamples, bool isActive, bool isDefault, List<String> tags, String dummyField, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PersonalizedRecommendationAlgorithmCopyWithImpl<$Res>
    implements _$PersonalizedRecommendationAlgorithmCopyWith<$Res> {
  __$PersonalizedRecommendationAlgorithmCopyWithImpl(this._self, this._then);

  final _PersonalizedRecommendationAlgorithm _self;
  final $Res Function(_PersonalizedRecommendationAlgorithm) _then;

/// Create a copy of PersonalizedRecommendationAlgorithm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? type = null,Object? accuracy = null,Object? precision = null,Object? recall = null,Object? f1Score = null,Object? featuresUsed = null,Object? weights = null,Object? personalizationLevel = null,Object? trainingSamples = null,Object? isActive = null,Object? isDefault = null,Object? tags = null,Object? dummyField = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PersonalizedRecommendationAlgorithm(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as RecommendationAlgorithmType,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,precision: null == precision ? _self.precision : precision // ignore: cast_nullable_to_non_nullable
as double,recall: null == recall ? _self.recall : recall // ignore: cast_nullable_to_non_nullable
as double,f1Score: null == f1Score ? _self.f1Score : f1Score // ignore: cast_nullable_to_non_nullable
as double,featuresUsed: null == featuresUsed ? _self._featuresUsed : featuresUsed // ignore: cast_nullable_to_non_nullable
as List<String>,weights: null == weights ? _self._weights : weights // ignore: cast_nullable_to_non_nullable
as List<String>,personalizationLevel: null == personalizationLevel ? _self.personalizationLevel : personalizationLevel // ignore: cast_nullable_to_non_nullable
as PersonalizationLevel,trainingSamples: null == trainingSamples ? _self.trainingSamples : trainingSamples // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,dummyField: null == dummyField ? _self.dummyField : dummyField // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
