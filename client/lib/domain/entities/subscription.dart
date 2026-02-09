import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required String description,
    required double priceMonthly,
    required double priceYearly,
    required bool isPremium,
    required String billingCycle,
    required List<String> features,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);
}

@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    required String id,
    required String userId,
    required String planId,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    required bool isAutoRenew,
    required String paymentMethod,
    required double amountPaid,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);
}

@freezed
class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    required String id,
    required String userId,
    required String type,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
    required String billingAddress,
    required bool isDefault,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
}

@freezed
class Purchase with _$Purchase {
  const factory Purchase({
    required String id,
    required String userId,
    required String productId,
    required String transactionId,
    required String receipt,
    required String status,
    required double amount,
    required String currency,
    required DateTime purchaseDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);
}

@freezed
class PaymentRecord with _$PaymentRecord {
  const factory PaymentRecord({
    required String id,
    required String userId,
    required String subscriptionId,
    required String paymentMethodId,
    required String transactionId,
    required double amount,
    required String currency,
    required String status,
    required DateTime paymentDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentRecord;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => _$PaymentRecordFromJson(json);
}