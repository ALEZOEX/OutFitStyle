// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionPlan _$SubscriptionPlanFromJson(Map<String, dynamic> json) =>
    _SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priceMonthly: (json['priceMonthly'] as num).toDouble(),
      priceYearly: (json['priceYearly'] as num).toDouble(),
      isPremium: json['isPremium'] as bool,
      billingCycle: json['billingCycle'] as String,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionPlanToJson(_SubscriptionPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'priceMonthly': instance.priceMonthly,
      'priceYearly': instance.priceYearly,
      'isPremium': instance.isPremium,
      'billingCycle': instance.billingCycle,
      'features': instance.features,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) =>
    _UserSubscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isAutoRenew: json['isAutoRenew'] as bool,
      paymentMethod: json['paymentMethod'] as String,
      amountPaid: (json['amountPaid'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserSubscriptionToJson(_UserSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isAutoRenew': instance.isAutoRenew,
      'paymentMethod': instance.paymentMethod,
      'amountPaid': instance.amountPaid,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    _PaymentMethod(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: json['cvv'] as String,
      cardholderName: json['cardholderName'] as String,
      billingAddress: json['billingAddress'] as String,
      isDefault: json['isDefault'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentMethodToJson(_PaymentMethod instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'cardNumber': instance.cardNumber,
      'expiryDate': instance.expiryDate,
      'cvv': instance.cvv,
      'cardholderName': instance.cardholderName,
      'billingAddress': instance.billingAddress,
      'isDefault': instance.isDefault,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_Purchase _$PurchaseFromJson(Map<String, dynamic> json) => _Purchase(
  id: json['id'] as String,
  userId: json['userId'] as String,
  productId: json['productId'] as String,
  transactionId: json['transactionId'] as String,
  receipt: json['receipt'] as String,
  status: json['status'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  purchaseDate: DateTime.parse(json['purchaseDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PurchaseToJson(_Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'productId': instance.productId,
  'transactionId': instance.transactionId,
  'receipt': instance.receipt,
  'status': instance.status,
  'amount': instance.amount,
  'currency': instance.currency,
  'purchaseDate': instance.purchaseDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_PaymentRecord _$PaymentRecordFromJson(Map<String, dynamic> json) =>
    _PaymentRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subscriptionId: json['subscriptionId'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      transactionId: json['transactionId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PaymentRecordToJson(_PaymentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'subscriptionId': instance.subscriptionId,
      'paymentMethodId': instance.paymentMethodId,
      'transactionId': instance.transactionId,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
