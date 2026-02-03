import 'package:freezed_annotation/freezed_annotation.dart';

part 'generator_state.freezed.dart';

@freezed
class GeneratorState with _$GeneratorState {
  const factory GeneratorState({
    @Default('casual') String occasion,
    @Default(<String>{}) Set<String> dismissed,
    @Default(false) bool isGenerating,
    String? error,
  }) = _GeneratorState;

  const GeneratorState._(); // Добавляем приватный конструктор для доступа к полям
}
