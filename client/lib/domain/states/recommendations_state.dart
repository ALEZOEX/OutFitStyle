import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/recommendation_entity.dart';

part 'recommendations_state.freezed.dart';

@freezed
class RecommendationsState with _$RecommendationsState {
  const factory RecommendationsState({
    @Default(AsyncValue.loading())
    AsyncValue<List<RecommendationRow>> recommendations,
    @Default(false) bool isLoading,
    String? error,
  }) = _RecommendationsState;

  const RecommendationsState._();
}