// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Achievement {

 String get id; String get title; String get description; String get icon; String get category; int get points; bool get isCompleted; DateTime? get completedAt; int get progress; int get target; String get reward; bool get isVisible; DateTime get createdAt; DateTime get updatedAt; String? get userId; bool get isUnlocked; int get currentProgress; int get targetValue; DateTime? get unlockedAt; String? get type;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.category, category) || other.category == category)&&(identical(other.points, points) || other.points == points)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.target, target) || other.target == target)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.currentProgress, currentProgress) || other.currentProgress == currentProgress)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,icon,category,points,isCompleted,completedAt,progress,target,reward,isVisible,createdAt,updatedAt,userId,isUnlocked,currentProgress,targetValue,unlockedAt,type]);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, icon: $icon, category: $category, points: $points, isCompleted: $isCompleted, completedAt: $completedAt, progress: $progress, target: $target, reward: $reward, isVisible: $isVisible, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, isUnlocked: $isUnlocked, currentProgress: $currentProgress, targetValue: $targetValue, unlockedAt: $unlockedAt, type: $type)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String icon, String category, int points, bool isCompleted, DateTime? completedAt, int progress, int target, String reward, bool isVisible, DateTime createdAt, DateTime updatedAt, String? userId, bool isUnlocked, int currentProgress, int targetValue, DateTime? unlockedAt, String? type
});




}
/// @nodoc
class _$AchievementCopyWithImpl<$Res>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._self, this._then);

  final Achievement _self;
  final $Res Function(Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? icon = null,Object? category = null,Object? points = null,Object? isCompleted = null,Object? completedAt = freezed,Object? progress = null,Object? target = null,Object? reward = null,Object? isVisible = null,Object? createdAt = null,Object? updatedAt = null,Object? userId = freezed,Object? isUnlocked = null,Object? currentProgress = null,Object? targetValue = null,Object? unlockedAt = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as String,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,currentProgress: null == currentProgress ? _self.currentProgress : currentProgress // ignore: cast_nullable_to_non_nullable
as int,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as int,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Achievement].
extension AchievementPatterns on Achievement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Achievement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Achievement value)  $default,){
final _that = this;
switch (_that) {
case _Achievement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Achievement value)?  $default,){
final _that = this;
switch (_that) {
case _Achievement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String icon,  String category,  int points,  bool isCompleted,  DateTime? completedAt,  int progress,  int target,  String reward,  bool isVisible,  DateTime createdAt,  DateTime updatedAt,  String? userId,  bool isUnlocked,  int currentProgress,  int targetValue,  DateTime? unlockedAt,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.icon,_that.category,_that.points,_that.isCompleted,_that.completedAt,_that.progress,_that.target,_that.reward,_that.isVisible,_that.createdAt,_that.updatedAt,_that.userId,_that.isUnlocked,_that.currentProgress,_that.targetValue,_that.unlockedAt,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String icon,  String category,  int points,  bool isCompleted,  DateTime? completedAt,  int progress,  int target,  String reward,  bool isVisible,  DateTime createdAt,  DateTime updatedAt,  String? userId,  bool isUnlocked,  int currentProgress,  int targetValue,  DateTime? unlockedAt,  String? type)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.id,_that.title,_that.description,_that.icon,_that.category,_that.points,_that.isCompleted,_that.completedAt,_that.progress,_that.target,_that.reward,_that.isVisible,_that.createdAt,_that.updatedAt,_that.userId,_that.isUnlocked,_that.currentProgress,_that.targetValue,_that.unlockedAt,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String icon,  String category,  int points,  bool isCompleted,  DateTime? completedAt,  int progress,  int target,  String reward,  bool isVisible,  DateTime createdAt,  DateTime updatedAt,  String? userId,  bool isUnlocked,  int currentProgress,  int targetValue,  DateTime? unlockedAt,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.icon,_that.category,_that.points,_that.isCompleted,_that.completedAt,_that.progress,_that.target,_that.reward,_that.isVisible,_that.createdAt,_that.updatedAt,_that.userId,_that.isUnlocked,_that.currentProgress,_that.targetValue,_that.unlockedAt,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement implements Achievement {
  const _Achievement({required this.id, required this.title, required this.description, required this.icon, required this.category, required this.points, this.isCompleted = false, this.completedAt, this.progress = 0, this.target = 1, this.reward = '', this.isVisible = true, required this.createdAt, required this.updatedAt, this.userId, this.isUnlocked = false, this.currentProgress = 0, this.targetValue = 1, this.unlockedAt, this.type});
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String icon;
@override final  String category;
@override final  int points;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completedAt;
@override@JsonKey() final  int progress;
@override@JsonKey() final  int target;
@override@JsonKey() final  String reward;
@override@JsonKey() final  bool isVisible;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? userId;
@override@JsonKey() final  bool isUnlocked;
@override@JsonKey() final  int currentProgress;
@override@JsonKey() final  int targetValue;
@override final  DateTime? unlockedAt;
@override final  String? type;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AchievementCopyWith<_Achievement> get copyWith => __$AchievementCopyWithImpl<_Achievement>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AchievementToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.category, category) || other.category == category)&&(identical(other.points, points) || other.points == points)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.target, target) || other.target == target)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.currentProgress, currentProgress) || other.currentProgress == currentProgress)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,description,icon,category,points,isCompleted,completedAt,progress,target,reward,isVisible,createdAt,updatedAt,userId,isUnlocked,currentProgress,targetValue,unlockedAt,type]);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, icon: $icon, category: $category, points: $points, isCompleted: $isCompleted, completedAt: $completedAt, progress: $progress, target: $target, reward: $reward, isVisible: $isVisible, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, isUnlocked: $isUnlocked, currentProgress: $currentProgress, targetValue: $targetValue, unlockedAt: $unlockedAt, type: $type)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String icon, String category, int points, bool isCompleted, DateTime? completedAt, int progress, int target, String reward, bool isVisible, DateTime createdAt, DateTime updatedAt, String? userId, bool isUnlocked, int currentProgress, int targetValue, DateTime? unlockedAt, String? type
});




}
/// @nodoc
class __$AchievementCopyWithImpl<$Res>
    implements _$AchievementCopyWith<$Res> {
  __$AchievementCopyWithImpl(this._self, this._then);

  final _Achievement _self;
  final $Res Function(_Achievement) _then;

/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? icon = null,Object? category = null,Object? points = null,Object? isCompleted = null,Object? completedAt = freezed,Object? progress = null,Object? target = null,Object? reward = null,Object? isVisible = null,Object? createdAt = null,Object? updatedAt = null,Object? userId = freezed,Object? isUnlocked = null,Object? currentProgress = null,Object? targetValue = null,Object? unlockedAt = freezed,Object? type = freezed,}) {
  return _then(_Achievement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as int,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as String,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,currentProgress: null == currentProgress ? _self.currentProgress : currentProgress // ignore: cast_nullable_to_non_nullable
as int,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as int,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
