import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState.initial() = _Initial;
  const factory OnboardingState.inProgress({
    required int currentStep,
    required int totalSteps,
  }) = _InProgress;
  const factory OnboardingState.completed() = _Completed;
  const factory OnboardingState.error({
    required String message,
  }) = _Error;
}