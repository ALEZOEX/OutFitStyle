import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/states/ui_states.dart';
import '../../../storage/local_storage.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await LocalStorage.prefs.setBool('onboarding_done', true);
      state = state.copyWith(
        isLoading: false,
        isComplete: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  bool isOnboardingCompleted() {
    return LocalStorage.prefs.getBool('onboarding_done') ?? false;
  }

  Future<void> nextStep() async {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  Future<void> previousStep() async {
    state = state.copyWith(currentStep: state.currentStep - 1);
  }
}
