import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/outfit_recommendation.dart';

part 'generator_state.freezed.dart';

@freezed
class GeneratorState with _$GeneratorState {
  const factory GeneratorState.initial() = _Initial;
  const factory GeneratorState.loading() = _Loading;
  const factory GeneratorState.loaded({
    required OutfitRecommendation recommendation,
  }) = _Loaded;
  const factory GeneratorState.error({
    required String message,
  }) = _Error;
}