import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding/onboarding_storage.dart';

final onboardingStorageProvider = Provider((ref) => OnboardingStorage());

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(onboardingStorageProvider);
  return storage.isDone();
});

final isOnboardingDoneProvider = Provider<bool>((ref) {
  final result = ref.watch(onboardingDoneProvider);
  return result.when(
    data: (done) => done,
    error: (_, __) => false,
    loading: () => false,
  );
});