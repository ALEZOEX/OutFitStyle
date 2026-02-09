import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:outfitstyle_client/domain/entities/outfit_recommendation.dart';

part 'recommendations_state.freezed.dart';

@freezed
class RecommendationsState with _$RecommendationsState {
  const factory RecommendationsState.initial() = RecommendationsInitial;
  const factory RecommendationsState.loading() = RecommendationsLoading;
  const factory RecommendationsState.loaded(List<OutfitRecommendation> recommendations) = RecommendationsLoaded;
  const factory RecommendationsState.generated(OutfitRecommendation recommendation) = RecommendationsGenerated;
  const factory RecommendationsState.error(String error) = RecommendationsError;
}