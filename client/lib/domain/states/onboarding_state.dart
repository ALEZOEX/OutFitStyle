import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState.initial() = OnboardingInitial;
  const factory OnboardingState.inProgress({required int step}) = OnboardingInProgress;
  const factory OnboardingState.complete() = OnboardingComplete;
}