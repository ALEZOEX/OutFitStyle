import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/states/onboarding_state.dart';

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingInitial());

  void nextStep() {
    // Implement onboarding logic
    state = const OnboardingInProgress(step: 1);
  }

  void completeOnboarding() {
    state = const OnboardingComplete();
  }
}