// test/architecture_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:outfitstyle_client/features/monetization/domain/entities/subscription_plan.dart';
import 'package:outfitstyle_client/features/achievements/domain/entities/achievement.dart';

void main() {
  group('Architecture Tests', () {
    test('SubscriptionPlan entity creation', () {
      const plan = SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        description: 'Premium subscription',
        priceMonthly: 9.99,
        priceYearly: 99.99,
        discountPercent: 16.7,
        features: ['feature1', 'feature2'],
        isPremium: true,
      );

      expect(plan.id, 'premium');
      expect(plan.name, 'Premium');
      expect(plan.isPremium, true);
    });

    test('UserSubscription entity creation', () {
      final subscription = UserSubscription(
        id: 'sub_123',
        planId: 'premium',
        status: 'active',
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2024, 1, 1),
        autoRenew: true,
        billingCycle: 'yearly',
      );

      expect(subscription.id, 'sub_123');
      expect(subscription.status, 'active');
      expect(subscription.autoRenew, true);
    });

    test('Achievement entity creation', () {
      final achievement = Achievement(
        id: 'first_outfit',
        title: 'First Outfit',
        description: 'Create your first outfit',
        icon: '👕',
        category: 'wardrobe',
        points: 10,
        isUnlocked: true,
        unlockedAt: DateTime(2023, 1, 1),
        progress: 1,
        maxProgress: 1,
      );

      expect(achievement.id, 'first_outfit');
      expect(achievement.isUnlocked, true);
      expect(achievement.points, 10);
    });
  });
}