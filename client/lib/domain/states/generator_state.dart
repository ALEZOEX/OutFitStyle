import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:outfitstyle_client/domain/entities/outfit_recommendation.dart';

part 'generator_state.freezed.dart';

@freezed
class GeneratorState with _$GeneratorState {
  const factory GeneratorState.initial() = GeneratorInitial;
  const factory GeneratorState.loading() = GeneratorLoading;
  const factory GeneratorState.success(OutfitRecommendation recommendation) = GeneratorSuccess;
  const factory GeneratorState.error(String error) = GeneratorError;
}