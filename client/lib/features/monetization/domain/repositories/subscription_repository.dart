// features/monetization/domain/repositories/subscription_repository.dart
abstract class SubscriptionRepository {
  // Получить доступные планы подписки
  Future<List<SubscriptionPlan>> getSubscriptionPlans();

  // Получить текущую подписку пользователя
  Future<UserSubscription?> getCurrentSubscription();

  // Оформить новую подписку
  Future<UserSubscription> subscribe({
    required String planId,
    required String billingCycle, // 'monthly' или 'yearly'
    required String paymentProvider, // 'stripe', 'yookassa', etc.
    String? paymentMethodId,
  });

  // Отменить подписку
  Future<void> cancelSubscription({bool immediate = false});

  // Возобновить подписку
  Future<void> reactivateSubscription();

  // Применить промокод
  Future<bool> applyPromoCode(String code);

  // Получить историю платежей
  Future<List<PaymentRecord>> getPaymentHistory();
}

class PaymentRecord {
  final String id;
  final double amount;
  final String currency;
  final DateTime date;
  final String status; // completed, failed, refunded
  final String method; // credit_card, paypal, apple_pay, google_pay
  final String? receiptUrl;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    required this.method,
    this.receiptUrl,
  });
}