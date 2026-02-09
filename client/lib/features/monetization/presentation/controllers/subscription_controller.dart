// features/monetization/presentation/controllers/subscription_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';

part 'subscription_controller.freezed.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState.initial() = _Initial;
  const factory SubscriptionState.loading() = _Loading;
  const factory SubscriptionState.loaded({
    required List<SubscriptionPlan> plans,
    UserSubscription? currentSubscription,
  }) = _Loaded;
  const factory SubscriptionState.error(String message) = _Error;
}

class SubscriptionController extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository;

  SubscriptionController(this._repository) : super(const SubscriptionState.initial());

  Future<void> loadPlans() async {
    state = const SubscriptionState.loading();
    try {
      final plans = await _repository.getSubscriptionPlans();
      final currentSubscription = await _repository.getCurrentSubscription();
      state = SubscriptionState.loaded(
        plans: plans,
        currentSubscription: currentSubscription,
      );
    } catch (e) {
      state = SubscriptionState.error(e.toString());
    }
  }

  Future<bool> subscribe({
    required String planId,
    required String billingCycle,
    required String paymentProvider,
    String? paymentMethodId,
  }) async {
    try {
      final subscription = await _repository.subscribe(
        planId: planId,
        billingCycle: billingCycle,
        paymentProvider: paymentProvider,
        paymentMethodId: paymentMethodId,
      );
      
      // Обновляем состояние
      final currentState = state;
      if (currentState is _Loaded) {
        state = SubscriptionState.loaded(
          plans: currentState.plans,
          currentSubscription: subscription,
        );
      }
      
      return true;
    } catch (e) {
      state = SubscriptionState.error('Failed to subscribe: $e');
      return false;
    }
  }

  Future<bool> cancelSubscription({bool immediate = false}) async {
    try {
      await _repository.cancelSubscription(immediate: immediate);

      // Обновляем состояние
      final currentState = state;
      if (currentState is _Loaded) {
        final currentSub = currentState.currentSubscription;
        if (currentSub != null) {
          final updatedSub = UserSubscription(
            id: currentSub.id,
            planId: currentSub.planId,
            status: 'cancelled',
            startDate: currentSub.startDate,
            endDate: currentSub.endDate,
            autoRenew: currentSub.autoRenew,
            billingCycle: currentSub.billingCycle,
            paymentProvider: currentSub.paymentProvider,
            externalSubscriptionId: currentSub.externalSubscriptionId,
          );
          state = SubscriptionState.loaded(
            plans: currentState.plans,
            currentSubscription: updatedSub,
          );
        }
      }

      return true;
    } catch (e) {
      state = SubscriptionState.error('Failed to cancel subscription: $e');
      return false;
    }
  }

  Future<bool> applyPromoCode(String code) async {
    try {
      final success = await _repository.applyPromoCode(code);
      if (success) {
        await loadPlans(); // Обновляем данные после применения промокода
      }
      return success;
    } catch (e) {
      state = SubscriptionState.error('Failed to apply promo code: $e');
      return false;
    }
  }
}