// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubscriptionPlan {

 String get id; String get name; String get description; double get priceMonthly; double get priceYearly; bool get isPremium; String get billingCycle; List<String> get features; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionPlanCopyWith<SubscriptionPlan> get copyWith => _$SubscriptionPlanCopyWithImpl<SubscriptionPlan>(this as SubscriptionPlan, _$identity);

  /// Serializes this SubscriptionPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceMonthly, priceMonthly) || other.priceMonthly == priceMonthly)&&(identical(other.priceYearly, priceYearly) || other.priceYearly == priceYearly)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&const DeepCollectionEquality().equals(other.features, features)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,priceMonthly,priceYearly,isPremium,billingCycle,const DeepCollectionEquality().hash(features),isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SubscriptionPlan(id: $id, name: $name, description: $description, priceMonthly: $priceMonthly, priceYearly: $priceYearly, isPremium: $isPremium, billingCycle: $billingCycle, features: $features, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SubscriptionPlanCopyWith<$Res>  {
  factory $SubscriptionPlanCopyWith(SubscriptionPlan value, $Res Function(SubscriptionPlan) _then) = _$SubscriptionPlanCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, double priceMonthly, double priceYearly, bool isPremium, String billingCycle, List<String> features, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SubscriptionPlanCopyWithImpl<$Res>
    implements $SubscriptionPlanCopyWith<$Res> {
  _$SubscriptionPlanCopyWithImpl(this._self, this._then);

  final SubscriptionPlan _self;
  final $Res Function(SubscriptionPlan) _then;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? priceMonthly = null,Object? priceYearly = null,Object? isPremium = null,Object? billingCycle = null,Object? features = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceMonthly: null == priceMonthly ? _self.priceMonthly : priceMonthly // ignore: cast_nullable_to_non_nullable
as double,priceYearly: null == priceYearly ? _self.priceYearly : priceYearly // ignore: cast_nullable_to_non_nullable
as double,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionPlan].
extension SubscriptionPlanPatterns on SubscriptionPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionPlan value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionPlan value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double priceMonthly,  double priceYearly,  bool isPremium,  String billingCycle,  List<String> features,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.priceMonthly,_that.priceYearly,_that.isPremium,_that.billingCycle,_that.features,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  double priceMonthly,  double priceYearly,  bool isPremium,  String billingCycle,  List<String> features,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPlan():
return $default(_that.id,_that.name,_that.description,_that.priceMonthly,_that.priceYearly,_that.isPremium,_that.billingCycle,_that.features,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  double priceMonthly,  double priceYearly,  bool isPremium,  String billingCycle,  List<String> features,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionPlan() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.priceMonthly,_that.priceYearly,_that.isPremium,_that.billingCycle,_that.features,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionPlan implements SubscriptionPlan {
  const _SubscriptionPlan({required this.id, required this.name, required this.description, required this.priceMonthly, required this.priceYearly, required this.isPremium, required this.billingCycle, required final  List<String> features, required this.isActive, required this.createdAt, required this.updatedAt}): _features = features;
  factory _SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);

@override final  String id;
@override final  String name;
@override final  String description;
@override final  double priceMonthly;
@override final  double priceYearly;
@override final  bool isPremium;
@override final  String billingCycle;
 final  List<String> _features;
@override List<String> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionPlanCopyWith<_SubscriptionPlan> get copyWith => __$SubscriptionPlanCopyWithImpl<_SubscriptionPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceMonthly, priceMonthly) || other.priceMonthly == priceMonthly)&&(identical(other.priceYearly, priceYearly) || other.priceYearly == priceYearly)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.billingCycle, billingCycle) || other.billingCycle == billingCycle)&&const DeepCollectionEquality().equals(other._features, _features)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,priceMonthly,priceYearly,isPremium,billingCycle,const DeepCollectionEquality().hash(_features),isActive,createdAt,updatedAt);

@override
String toString() {
  return 'SubscriptionPlan(id: $id, name: $name, description: $description, priceMonthly: $priceMonthly, priceYearly: $priceYearly, isPremium: $isPremium, billingCycle: $billingCycle, features: $features, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionPlanCopyWith<$Res> implements $SubscriptionPlanCopyWith<$Res> {
  factory _$SubscriptionPlanCopyWith(_SubscriptionPlan value, $Res Function(_SubscriptionPlan) _then) = __$SubscriptionPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, double priceMonthly, double priceYearly, bool isPremium, String billingCycle, List<String> features, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SubscriptionPlanCopyWithImpl<$Res>
    implements _$SubscriptionPlanCopyWith<$Res> {
  __$SubscriptionPlanCopyWithImpl(this._self, this._then);

  final _SubscriptionPlan _self;
  final $Res Function(_SubscriptionPlan) _then;

/// Create a copy of SubscriptionPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? priceMonthly = null,Object? priceYearly = null,Object? isPremium = null,Object? billingCycle = null,Object? features = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SubscriptionPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceMonthly: null == priceMonthly ? _self.priceMonthly : priceMonthly // ignore: cast_nullable_to_non_nullable
as double,priceYearly: null == priceYearly ? _self.priceYearly : priceYearly // ignore: cast_nullable_to_non_nullable
as double,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,billingCycle: null == billingCycle ? _self.billingCycle : billingCycle // ignore: cast_nullable_to_non_nullable
as String,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserSubscription {

 String get id; String get userId; String get planId; String get status; DateTime get startDate; DateTime get endDate; bool get isAutoRenew; String get paymentMethod; double get amountPaid; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSubscriptionCopyWith<UserSubscription> get copyWith => _$UserSubscriptionCopyWithImpl<UserSubscription>(this as UserSubscription, _$identity);

  /// Serializes this UserSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isAutoRenew, isAutoRenew) || other.isAutoRenew == isAutoRenew)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,planId,status,startDate,endDate,isAutoRenew,paymentMethod,amountPaid,createdAt,updatedAt);

@override
String toString() {
  return 'UserSubscription(id: $id, userId: $userId, planId: $planId, status: $status, startDate: $startDate, endDate: $endDate, isAutoRenew: $isAutoRenew, paymentMethod: $paymentMethod, amountPaid: $amountPaid, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserSubscriptionCopyWith<$Res>  {
  factory $UserSubscriptionCopyWith(UserSubscription value, $Res Function(UserSubscription) _then) = _$UserSubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String planId, String status, DateTime startDate, DateTime endDate, bool isAutoRenew, String paymentMethod, double amountPaid, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$UserSubscriptionCopyWithImpl<$Res>
    implements $UserSubscriptionCopyWith<$Res> {
  _$UserSubscriptionCopyWithImpl(this._self, this._then);

  final UserSubscription _self;
  final $Res Function(UserSubscription) _then;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? planId = null,Object? status = null,Object? startDate = null,Object? endDate = null,Object? isAutoRenew = null,Object? paymentMethod = null,Object? amountPaid = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isAutoRenew: null == isAutoRenew ? _self.isAutoRenew : isAutoRenew // ignore: cast_nullable_to_non_nullable
as bool,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UserSubscription].
extension UserSubscriptionPatterns on UserSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSubscription value)  $default,){
final _that = this;
switch (_that) {
case _UserSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String planId,  String status,  DateTime startDate,  DateTime endDate,  bool isAutoRenew,  String paymentMethod,  double amountPaid,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
return $default(_that.id,_that.userId,_that.planId,_that.status,_that.startDate,_that.endDate,_that.isAutoRenew,_that.paymentMethod,_that.amountPaid,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String planId,  String status,  DateTime startDate,  DateTime endDate,  bool isAutoRenew,  String paymentMethod,  double amountPaid,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserSubscription():
return $default(_that.id,_that.userId,_that.planId,_that.status,_that.startDate,_that.endDate,_that.isAutoRenew,_that.paymentMethod,_that.amountPaid,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String planId,  String status,  DateTime startDate,  DateTime endDate,  bool isAutoRenew,  String paymentMethod,  double amountPaid,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
return $default(_that.id,_that.userId,_that.planId,_that.status,_that.startDate,_that.endDate,_that.isAutoRenew,_that.paymentMethod,_that.amountPaid,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSubscription implements UserSubscription {
  const _UserSubscription({required this.id, required this.userId, required this.planId, required this.status, required this.startDate, required this.endDate, required this.isAutoRenew, required this.paymentMethod, required this.amountPaid, required this.createdAt, required this.updatedAt});
  factory _UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String planId;
@override final  String status;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  bool isAutoRenew;
@override final  String paymentMethod;
@override final  double amountPaid;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSubscriptionCopyWith<_UserSubscription> get copyWith => __$UserSubscriptionCopyWithImpl<_UserSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSubscription&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isAutoRenew, isAutoRenew) || other.isAutoRenew == isAutoRenew)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.amountPaid, amountPaid) || other.amountPaid == amountPaid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,planId,status,startDate,endDate,isAutoRenew,paymentMethod,amountPaid,createdAt,updatedAt);

@override
String toString() {
  return 'UserSubscription(id: $id, userId: $userId, planId: $planId, status: $status, startDate: $startDate, endDate: $endDate, isAutoRenew: $isAutoRenew, paymentMethod: $paymentMethod, amountPaid: $amountPaid, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserSubscriptionCopyWith<$Res> implements $UserSubscriptionCopyWith<$Res> {
  factory _$UserSubscriptionCopyWith(_UserSubscription value, $Res Function(_UserSubscription) _then) = __$UserSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String planId, String status, DateTime startDate, DateTime endDate, bool isAutoRenew, String paymentMethod, double amountPaid, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$UserSubscriptionCopyWithImpl<$Res>
    implements _$UserSubscriptionCopyWith<$Res> {
  __$UserSubscriptionCopyWithImpl(this._self, this._then);

  final _UserSubscription _self;
  final $Res Function(_UserSubscription) _then;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? planId = null,Object? status = null,Object? startDate = null,Object? endDate = null,Object? isAutoRenew = null,Object? paymentMethod = null,Object? amountPaid = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_UserSubscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isAutoRenew: null == isAutoRenew ? _self.isAutoRenew : isAutoRenew // ignore: cast_nullable_to_non_nullable
as bool,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,amountPaid: null == amountPaid ? _self.amountPaid : amountPaid // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PaymentMethod {

 String get id; String get userId; String get type; String get cardNumber; String get expiryDate; String get cvv; String get cardholderName; String get billingAddress; bool get isDefault; bool get isActive; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PaymentMethod
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentMethodCopyWith<PaymentMethod> get copyWith => _$PaymentMethodCopyWithImpl<PaymentMethod>(this as PaymentMethod, _$identity);

  /// Serializes this PaymentMethod to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.cardNumber, cardNumber) || other.cardNumber == cardNumber)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.cvv, cvv) || other.cvv == cvv)&&(identical(other.cardholderName, cardholderName) || other.cardholderName == cardholderName)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,cardNumber,expiryDate,cvv,cardholderName,billingAddress,isDefault,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PaymentMethod(id: $id, userId: $userId, type: $type, cardNumber: $cardNumber, expiryDate: $expiryDate, cvv: $cvv, cardholderName: $cardholderName, billingAddress: $billingAddress, isDefault: $isDefault, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentMethodCopyWith<$Res>  {
  factory $PaymentMethodCopyWith(PaymentMethod value, $Res Function(PaymentMethod) _then) = _$PaymentMethodCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String type, String cardNumber, String expiryDate, String cvv, String cardholderName, String billingAddress, bool isDefault, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PaymentMethodCopyWithImpl<$Res>
    implements $PaymentMethodCopyWith<$Res> {
  _$PaymentMethodCopyWithImpl(this._self, this._then);

  final PaymentMethod _self;
  final $Res Function(PaymentMethod) _then;

/// Create a copy of PaymentMethod
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? cardNumber = null,Object? expiryDate = null,Object? cvv = null,Object? cardholderName = null,Object? billingAddress = null,Object? isDefault = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,cardNumber: null == cardNumber ? _self.cardNumber : cardNumber // ignore: cast_nullable_to_non_nullable
as String,expiryDate: null == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String,cvv: null == cvv ? _self.cvv : cvv // ignore: cast_nullable_to_non_nullable
as String,cardholderName: null == cardholderName ? _self.cardholderName : cardholderName // ignore: cast_nullable_to_non_nullable
as String,billingAddress: null == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentMethod].
extension PaymentMethodPatterns on PaymentMethod {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentMethod value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentMethod() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentMethod value)  $default,){
final _that = this;
switch (_that) {
case _PaymentMethod():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentMethod value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentMethod() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  String cardNumber,  String expiryDate,  String cvv,  String cardholderName,  String billingAddress,  bool isDefault,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentMethod() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.cardNumber,_that.expiryDate,_that.cvv,_that.cardholderName,_that.billingAddress,_that.isDefault,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String type,  String cardNumber,  String expiryDate,  String cvv,  String cardholderName,  String billingAddress,  bool isDefault,  bool isActive,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentMethod():
return $default(_that.id,_that.userId,_that.type,_that.cardNumber,_that.expiryDate,_that.cvv,_that.cardholderName,_that.billingAddress,_that.isDefault,_that.isActive,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String type,  String cardNumber,  String expiryDate,  String cvv,  String cardholderName,  String billingAddress,  bool isDefault,  bool isActive,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentMethod() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.cardNumber,_that.expiryDate,_that.cvv,_that.cardholderName,_that.billingAddress,_that.isDefault,_that.isActive,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentMethod implements PaymentMethod {
  const _PaymentMethod({required this.id, required this.userId, required this.type, required this.cardNumber, required this.expiryDate, required this.cvv, required this.cardholderName, required this.billingAddress, required this.isDefault, required this.isActive, required this.createdAt, required this.updatedAt});
  factory _PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String type;
@override final  String cardNumber;
@override final  String expiryDate;
@override final  String cvv;
@override final  String cardholderName;
@override final  String billingAddress;
@override final  bool isDefault;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentMethodCopyWith<_PaymentMethod> get copyWith => __$PaymentMethodCopyWithImpl<_PaymentMethod>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentMethodToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentMethod&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.cardNumber, cardNumber) || other.cardNumber == cardNumber)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.cvv, cvv) || other.cvv == cvv)&&(identical(other.cardholderName, cardholderName) || other.cardholderName == cardholderName)&&(identical(other.billingAddress, billingAddress) || other.billingAddress == billingAddress)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,cardNumber,expiryDate,cvv,cardholderName,billingAddress,isDefault,isActive,createdAt,updatedAt);

@override
String toString() {
  return 'PaymentMethod(id: $id, userId: $userId, type: $type, cardNumber: $cardNumber, expiryDate: $expiryDate, cvv: $cvv, cardholderName: $cardholderName, billingAddress: $billingAddress, isDefault: $isDefault, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentMethodCopyWith<$Res> implements $PaymentMethodCopyWith<$Res> {
  factory _$PaymentMethodCopyWith(_PaymentMethod value, $Res Function(_PaymentMethod) _then) = __$PaymentMethodCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, String cardNumber, String expiryDate, String cvv, String cardholderName, String billingAddress, bool isDefault, bool isActive, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PaymentMethodCopyWithImpl<$Res>
    implements _$PaymentMethodCopyWith<$Res> {
  __$PaymentMethodCopyWithImpl(this._self, this._then);

  final _PaymentMethod _self;
  final $Res Function(_PaymentMethod) _then;

/// Create a copy of PaymentMethod
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? cardNumber = null,Object? expiryDate = null,Object? cvv = null,Object? cardholderName = null,Object? billingAddress = null,Object? isDefault = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PaymentMethod(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,cardNumber: null == cardNumber ? _self.cardNumber : cardNumber // ignore: cast_nullable_to_non_nullable
as String,expiryDate: null == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as String,cvv: null == cvv ? _self.cvv : cvv // ignore: cast_nullable_to_non_nullable
as String,cardholderName: null == cardholderName ? _self.cardholderName : cardholderName // ignore: cast_nullable_to_non_nullable
as String,billingAddress: null == billingAddress ? _self.billingAddress : billingAddress // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Purchase {

 String get id; String get userId; String get productId; String get transactionId; String get receipt; String get status; double get amount; String get currency; DateTime get purchaseDate; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseCopyWith<Purchase> get copyWith => _$PurchaseCopyWithImpl<Purchase>(this as Purchase, _$identity);

  /// Serializes this Purchase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Purchase&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.receipt, receipt) || other.receipt == receipt)&&(identical(other.status, status) || other.status == status)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,productId,transactionId,receipt,status,amount,currency,purchaseDate,createdAt,updatedAt);

@override
String toString() {
  return 'Purchase(id: $id, userId: $userId, productId: $productId, transactionId: $transactionId, receipt: $receipt, status: $status, amount: $amount, currency: $currency, purchaseDate: $purchaseDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseCopyWith<$Res>  {
  factory $PurchaseCopyWith(Purchase value, $Res Function(Purchase) _then) = _$PurchaseCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String productId, String transactionId, String receipt, String status, double amount, String currency, DateTime purchaseDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PurchaseCopyWithImpl<$Res>
    implements $PurchaseCopyWith<$Res> {
  _$PurchaseCopyWithImpl(this._self, this._then);

  final Purchase _self;
  final $Res Function(Purchase) _then;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? productId = null,Object? transactionId = null,Object? receipt = null,Object? status = null,Object? amount = null,Object? currency = null,Object? purchaseDate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,receipt: null == receipt ? _self.receipt : receipt // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Purchase].
extension PurchasePatterns on Purchase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Purchase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Purchase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Purchase value)  $default,){
final _that = this;
switch (_that) {
case _Purchase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Purchase value)?  $default,){
final _that = this;
switch (_that) {
case _Purchase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String productId,  String transactionId,  String receipt,  String status,  double amount,  String currency,  DateTime purchaseDate,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Purchase() when $default != null:
return $default(_that.id,_that.userId,_that.productId,_that.transactionId,_that.receipt,_that.status,_that.amount,_that.currency,_that.purchaseDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String productId,  String transactionId,  String receipt,  String status,  double amount,  String currency,  DateTime purchaseDate,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Purchase():
return $default(_that.id,_that.userId,_that.productId,_that.transactionId,_that.receipt,_that.status,_that.amount,_that.currency,_that.purchaseDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String productId,  String transactionId,  String receipt,  String status,  double amount,  String currency,  DateTime purchaseDate,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Purchase() when $default != null:
return $default(_that.id,_that.userId,_that.productId,_that.transactionId,_that.receipt,_that.status,_that.amount,_that.currency,_that.purchaseDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Purchase implements Purchase {
  const _Purchase({required this.id, required this.userId, required this.productId, required this.transactionId, required this.receipt, required this.status, required this.amount, required this.currency, required this.purchaseDate, required this.createdAt, required this.updatedAt});
  factory _Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String productId;
@override final  String transactionId;
@override final  String receipt;
@override final  String status;
@override final  double amount;
@override final  String currency;
@override final  DateTime purchaseDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseCopyWith<_Purchase> get copyWith => __$PurchaseCopyWithImpl<_Purchase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Purchase&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.receipt, receipt) || other.receipt == receipt)&&(identical(other.status, status) || other.status == status)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,productId,transactionId,receipt,status,amount,currency,purchaseDate,createdAt,updatedAt);

@override
String toString() {
  return 'Purchase(id: $id, userId: $userId, productId: $productId, transactionId: $transactionId, receipt: $receipt, status: $status, amount: $amount, currency: $currency, purchaseDate: $purchaseDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseCopyWith<$Res> implements $PurchaseCopyWith<$Res> {
  factory _$PurchaseCopyWith(_Purchase value, $Res Function(_Purchase) _then) = __$PurchaseCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String productId, String transactionId, String receipt, String status, double amount, String currency, DateTime purchaseDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PurchaseCopyWithImpl<$Res>
    implements _$PurchaseCopyWith<$Res> {
  __$PurchaseCopyWithImpl(this._self, this._then);

  final _Purchase _self;
  final $Res Function(_Purchase) _then;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? productId = null,Object? transactionId = null,Object? receipt = null,Object? status = null,Object? amount = null,Object? currency = null,Object? purchaseDate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Purchase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,receipt: null == receipt ? _self.receipt : receipt // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PaymentRecord {

 String get id; String get userId; String get subscriptionId; String get paymentMethodId; String get transactionId; double get amount; String get currency; String get status; DateTime get paymentDate; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRecordCopyWith<PaymentRecord> get copyWith => _$PaymentRecordCopyWithImpl<PaymentRecord>(this as PaymentRecord, _$identity);

  /// Serializes this PaymentRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,subscriptionId,paymentMethodId,transactionId,amount,currency,status,paymentDate,createdAt,updatedAt);

@override
String toString() {
  return 'PaymentRecord(id: $id, userId: $userId, subscriptionId: $subscriptionId, paymentMethodId: $paymentMethodId, transactionId: $transactionId, amount: $amount, currency: $currency, status: $status, paymentDate: $paymentDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PaymentRecordCopyWith<$Res>  {
  factory $PaymentRecordCopyWith(PaymentRecord value, $Res Function(PaymentRecord) _then) = _$PaymentRecordCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String subscriptionId, String paymentMethodId, String transactionId, double amount, String currency, String status, DateTime paymentDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$PaymentRecordCopyWithImpl<$Res>
    implements $PaymentRecordCopyWith<$Res> {
  _$PaymentRecordCopyWithImpl(this._self, this._then);

  final PaymentRecord _self;
  final $Res Function(PaymentRecord) _then;

/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? subscriptionId = null,Object? paymentMethodId = null,Object? transactionId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paymentDate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRecord].
extension PaymentRecordPatterns on PaymentRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRecord value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRecord value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String subscriptionId,  String paymentMethodId,  String transactionId,  double amount,  String currency,  String status,  DateTime paymentDate,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
return $default(_that.id,_that.userId,_that.subscriptionId,_that.paymentMethodId,_that.transactionId,_that.amount,_that.currency,_that.status,_that.paymentDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String subscriptionId,  String paymentMethodId,  String transactionId,  double amount,  String currency,  String status,  DateTime paymentDate,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentRecord():
return $default(_that.id,_that.userId,_that.subscriptionId,_that.paymentMethodId,_that.transactionId,_that.amount,_that.currency,_that.status,_that.paymentDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String subscriptionId,  String paymentMethodId,  String transactionId,  double amount,  String currency,  String status,  DateTime paymentDate,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRecord() when $default != null:
return $default(_that.id,_that.userId,_that.subscriptionId,_that.paymentMethodId,_that.transactionId,_that.amount,_that.currency,_that.status,_that.paymentDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRecord implements PaymentRecord {
  const _PaymentRecord({required this.id, required this.userId, required this.subscriptionId, required this.paymentMethodId, required this.transactionId, required this.amount, required this.currency, required this.status, required this.paymentDate, required this.createdAt, required this.updatedAt});
  factory _PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String subscriptionId;
@override final  String paymentMethodId;
@override final  String transactionId;
@override final  double amount;
@override final  String currency;
@override final  String status;
@override final  DateTime paymentDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRecordCopyWith<_PaymentRecord> get copyWith => __$PaymentRecordCopyWithImpl<_PaymentRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.subscriptionId, subscriptionId) || other.subscriptionId == subscriptionId)&&(identical(other.paymentMethodId, paymentMethodId) || other.paymentMethodId == paymentMethodId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,subscriptionId,paymentMethodId,transactionId,amount,currency,status,paymentDate,createdAt,updatedAt);

@override
String toString() {
  return 'PaymentRecord(id: $id, userId: $userId, subscriptionId: $subscriptionId, paymentMethodId: $paymentMethodId, transactionId: $transactionId, amount: $amount, currency: $currency, status: $status, paymentDate: $paymentDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentRecordCopyWith<$Res> implements $PaymentRecordCopyWith<$Res> {
  factory _$PaymentRecordCopyWith(_PaymentRecord value, $Res Function(_PaymentRecord) _then) = __$PaymentRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String subscriptionId, String paymentMethodId, String transactionId, double amount, String currency, String status, DateTime paymentDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$PaymentRecordCopyWithImpl<$Res>
    implements _$PaymentRecordCopyWith<$Res> {
  __$PaymentRecordCopyWithImpl(this._self, this._then);

  final _PaymentRecord _self;
  final $Res Function(_PaymentRecord) _then;

/// Create a copy of PaymentRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? subscriptionId = null,Object? paymentMethodId = null,Object? transactionId = null,Object? amount = null,Object? currency = null,Object? status = null,Object? paymentDate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_PaymentRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,subscriptionId: null == subscriptionId ? _self.subscriptionId : subscriptionId // ignore: cast_nullable_to_non_nullable
as String,paymentMethodId: null == paymentMethodId ? _self.paymentMethodId : paymentMethodId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
