// Re-export провайдеров онбординга
export 'presentation/providers/onboarding_provider.dart';

// Для обратной совместимости
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_storage.dart';

final onboardingStorageProviderLegacy = Provider((ref) => OnboardingStorage());

final onboardingDoneProviderLegacy = FutureProvider<bool>((ref) async {
  final storage = ref.read(onboardingStorageProviderLegacy);
  return storage.isDone();
});

final isOnboardingDoneProviderLegacy = Provider<bool>((ref) {
  final result = ref.watch(onboardingDoneProviderLegacy);
  return result.when(
    data: (done) => done,
    error: (_, __) => false,
    loading: () => false,
  );
});
