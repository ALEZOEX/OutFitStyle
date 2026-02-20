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

/// Уникальный идентификатор достижения
 String get id;/// Заголовок достижения
 String get title;/// Описание достижения
 String get description;/// Иконка достижения (emoji или название иконки)
 String get icon;/// Категория достижения
 AchievementCategory get category;/// Количество очков за достижение
 int get points;/// Текущий прогресс выполнения
 int get currentProgress;/// Целевое значение для завершения
 int get targetValue;/// Разблокировано ли достижение
 bool get isUnlocked;/// Дата разблокировки достижения
 DateTime? get unlockedAt;/// Дата создания записи о достижении
 DateTime? get createdAt;/// Дата последнего обновления
 DateTime? get updatedAt;/// ID пользователя (если привязано к конкретному пользователю)
 String? get userId;/// Награда за достижение (например, бонусные очки)
 String get reward;/// Видимо ли достижение в списке
 bool get isVisible;/// Тип достижения для трекинга
 String? get type;
/// Create a copy of Achievement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AchievementCopyWith<Achievement> get copyWith => _$AchievementCopyWithImpl<Achievement>(this as Achievement, _$identity);

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.category, category) || other.category == category)&&(identical(other.points, points) || other.points == points)&&(identical(other.currentProgress, currentProgress) || other.currentProgress == currentProgress)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,icon,category,points,currentProgress,targetValue,isUnlocked,unlockedAt,createdAt,updatedAt,userId,reward,isVisible,type);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, icon: $icon, category: $category, points: $points, currentProgress: $currentProgress, targetValue: $targetValue, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, reward: $reward, isVisible: $isVisible, type: $type)';
}


}

/// @nodoc
abstract mixin class $AchievementCopyWith<$Res>  {
  factory $AchievementCopyWith(Achievement value, $Res Function(Achievement) _then) = _$AchievementCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String icon, AchievementCategory category, int points, int currentProgress, int targetValue, bool isUnlocked, DateTime? unlockedAt, DateTime? createdAt, DateTime? updatedAt, String? userId, String reward, bool isVisible, String? type
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? icon = null,Object? category = null,Object? points = null,Object? currentProgress = null,Object? targetValue = null,Object? isUnlocked = null,Object? unlockedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? userId = freezed,Object? reward = null,Object? isVisible = null,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,currentProgress: null == currentProgress ? _self.currentProgress : currentProgress // ignore: cast_nullable_to_non_nullable
as int,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as int,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as String,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String icon,  AchievementCategory category,  int points,  int currentProgress,  int targetValue,  bool isUnlocked,  DateTime? unlockedAt,  DateTime? createdAt,  DateTime? updatedAt,  String? userId,  String reward,  bool isVisible,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.icon,_that.category,_that.points,_that.currentProgress,_that.targetValue,_that.isUnlocked,_that.unlockedAt,_that.createdAt,_that.updatedAt,_that.userId,_that.reward,_that.isVisible,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String icon,  AchievementCategory category,  int points,  int currentProgress,  int targetValue,  bool isUnlocked,  DateTime? unlockedAt,  DateTime? createdAt,  DateTime? updatedAt,  String? userId,  String reward,  bool isVisible,  String? type)  $default,) {final _that = this;
switch (_that) {
case _Achievement():
return $default(_that.id,_that.title,_that.description,_that.icon,_that.category,_that.points,_that.currentProgress,_that.targetValue,_that.isUnlocked,_that.unlockedAt,_that.createdAt,_that.updatedAt,_that.userId,_that.reward,_that.isVisible,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String icon,  AchievementCategory category,  int points,  int currentProgress,  int targetValue,  bool isUnlocked,  DateTime? unlockedAt,  DateTime? createdAt,  DateTime? updatedAt,  String? userId,  String reward,  bool isVisible,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _Achievement() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.icon,_that.category,_that.points,_that.currentProgress,_that.targetValue,_that.isUnlocked,_that.unlockedAt,_that.createdAt,_that.updatedAt,_that.userId,_that.reward,_that.isVisible,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Achievement implements Achievement {
  const _Achievement({required this.id, required this.title, required this.description, required this.icon, required this.category, required this.points, this.currentProgress = 0, this.targetValue = 1, this.isUnlocked = false, this.unlockedAt, this.createdAt, this.updatedAt, this.userId, this.reward = '', this.isVisible = true, this.type});
  factory _Achievement.fromJson(Map<String, dynamic> json) => _$AchievementFromJson(json);

/// Уникальный идентификатор достижения
@override final  String id;
/// Заголовок достижения
@override final  String title;
/// Описание достижения
@override final  String description;
/// Иконка достижения (emoji или название иконки)
@override final  String icon;
/// Категория достижения
@override final  AchievementCategory category;
/// Количество очков за достижение
@override final  int points;
/// Текущий прогресс выполнения
@override@JsonKey() final  int currentProgress;
/// Целевое значение для завершения
@override@JsonKey() final  int targetValue;
/// Разблокировано ли достижение
@override@JsonKey() final  bool isUnlocked;
/// Дата разблокировки достижения
@override final  DateTime? unlockedAt;
/// Дата создания записи о достижении
@override final  DateTime? createdAt;
/// Дата последнего обновления
@override final  DateTime? updatedAt;
/// ID пользователя (если привязано к конкретному пользователю)
@override final  String? userId;
/// Награда за достижение (например, бонусные очки)
@override@JsonKey() final  String reward;
/// Видимо ли достижение в списке
@override@JsonKey() final  bool isVisible;
/// Тип достижения для трекинга
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Achievement&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.category, category) || other.category == category)&&(identical(other.points, points) || other.points == points)&&(identical(other.currentProgress, currentProgress) || other.currentProgress == currentProgress)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.isUnlocked, isUnlocked) || other.isUnlocked == isUnlocked)&&(identical(other.unlockedAt, unlockedAt) || other.unlockedAt == unlockedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.reward, reward) || other.reward == reward)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,icon,category,points,currentProgress,targetValue,isUnlocked,unlockedAt,createdAt,updatedAt,userId,reward,isVisible,type);

@override
String toString() {
  return 'Achievement(id: $id, title: $title, description: $description, icon: $icon, category: $category, points: $points, currentProgress: $currentProgress, targetValue: $targetValue, isUnlocked: $isUnlocked, unlockedAt: $unlockedAt, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId, reward: $reward, isVisible: $isVisible, type: $type)';
}


}

/// @nodoc
abstract mixin class _$AchievementCopyWith<$Res> implements $AchievementCopyWith<$Res> {
  factory _$AchievementCopyWith(_Achievement value, $Res Function(_Achievement) _then) = __$AchievementCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String icon, AchievementCategory category, int points, int currentProgress, int targetValue, bool isUnlocked, DateTime? unlockedAt, DateTime? createdAt, DateTime? updatedAt, String? userId, String reward, bool isVisible, String? type
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? icon = null,Object? category = null,Object? points = null,Object? currentProgress = null,Object? targetValue = null,Object? isUnlocked = null,Object? unlockedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? userId = freezed,Object? reward = null,Object? isVisible = null,Object? type = freezed,}) {
  return _then(_Achievement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AchievementCategory,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,currentProgress: null == currentProgress ? _self.currentProgress : currentProgress // ignore: cast_nullable_to_non_nullable
as int,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as int,isUnlocked: null == isUnlocked ? _self.isUnlocked : isUnlocked // ignore: cast_nullable_to_non_nullable
as bool,unlockedAt: freezed == unlockedAt ? _self.unlockedAt : unlockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as String,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
