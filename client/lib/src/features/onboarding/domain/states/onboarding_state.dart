/// Состояние онбординга
abstract class OnboardingState {
  const OnboardingState();
}

/// Начальное состояние
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Онбординг завершён
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
