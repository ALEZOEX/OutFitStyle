import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref.watch(localStorageProvider));
});

class OnboardingController extends StateNotifier<OnboardingState> {
  final SharedPreferences _prefs;

  OnboardingController(this._prefs) : super(const OnboardingState());

  Future<void> completeOnboarding() async {
    // Логика завершения онбординга
    await _prefs.setBool('onboarding_done', true);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_done') ?? false;
  }
}

class OnboardingState {}
