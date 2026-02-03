import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/recommendation_entity.dart';
import 'async_state.dart';

part 'recommendations_state.freezed.dart';

@freezed
class RecommendationsState with _$RecommendationsState {
  const factory RecommendationsState({
    @Default(AsyncLoading<List<RecommendationRow>>())
    AsyncState<List<RecommendationRow>> recommendations,
    @Default(false) bool isLoading,
    String? error,
  }) = _RecommendationsState;

  const RecommendationsState._();
}