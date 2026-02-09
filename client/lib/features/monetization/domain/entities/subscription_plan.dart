// features/monetization/domain/entities/subscription_plan.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_plan.freezed.dart';

@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required String description,
    required double priceMonthly,
    required double priceYearly,
    required double discountPercent, // Скидка при годовой подписке
    required List<String> features,
    required bool isPremium,
  }) = _SubscriptionPlan;
}

@freezed
class UserSubscription with _$UserSubscription {
  const factory UserSubscription({
    required String id,
    required String planId,
    required String status, // active, cancelled, expired
    required DateTime startDate,
    required DateTime endDate,
    required bool autoRenew,
    required String billingCycle, // monthly, yearly
    String? paymentProvider,
    String? externalSubscriptionId,
  }) = _UserSubscription;

  factory UserSubscription.empty() => UserSubscription(
    id: '',
    planId: '',
    status: 'inactive',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    autoRenew: false,
    billingCycle: 'monthly',
  );
}