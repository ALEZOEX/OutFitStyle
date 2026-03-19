/// Состояние генератора нарядов
class GeneratorState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? generatedOutfit;

  const GeneratorState({
    this.isLoading = false,
    this.error,
    this.generatedOutfit,
  });

  factory GeneratorState.initial() => const GeneratorState();

  GeneratorState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? generatedOutfit,
  }) {
    return GeneratorState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      generatedOutfit: generatedOutfit ?? this.generatedOutfit,
    );
  }
}
