// app/providers/monetization_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection.dart';
import '../../features/monetization/presentation/controllers/subscription_controller.dart';

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  return SubscriptionController(repository);
});