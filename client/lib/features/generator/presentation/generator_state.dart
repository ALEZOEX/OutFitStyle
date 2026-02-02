import 'package:equatable/equatable.dart';

class GeneratorState extends Equatable {
  final String occasion; // daily/date/office/walk...
  final bool isGenerating;
  final String? error;
  final Set<String> dismissed; // session-only

  const GeneratorState({
    required this.occasion,
    required this.isGenerating,
    required this.dismissed,
    this.error,
  });

  GeneratorState copyWith({
    String? occasion,
    bool? isGenerating,
    String? error,
    Set<String>? dismissed,
  }) {
    return GeneratorState(
      occasion: occasion ?? this.occasion,
      isGenerating: isGenerating ?? this.isGenerating,
      dismissed: dismissed ?? this.dismissed,
      error: error,
    );
  }

  factory GeneratorState.initial() => const GeneratorState(
        occasion: 'daily',
        isGenerating: false,
        dismissed: <String>{},
        error: null,
      );

  @override
  List<Object?> get props => [occasion, isGenerating, error, dismissed];
}