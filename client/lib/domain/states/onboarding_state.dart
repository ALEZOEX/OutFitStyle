import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentStep,
    @Default(false) bool isComplete,
    @Default(false) bool isLoading,
    String? error,
  }) = _OnboardingState;

  const OnboardingState._();
}