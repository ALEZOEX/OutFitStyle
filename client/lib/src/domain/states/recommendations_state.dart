import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/outfit_recommendation.dart';

part 'recommendations_state.freezed.dart';

@freezed
class RecommendationsState with _$RecommendationsState {
  const factory RecommendationsState.initial() = _Initial;
  const factory RecommendationsState.loading() = _Loading;
  const factory RecommendationsState.loaded({
    required List<OutfitRecommendation> recommendations,
  }) = _Loaded;
  const factory RecommendationsState.error({
    required String message,
  }) = _Error;
  const factory RecommendationsState.detail({
    required OutfitRecommendation recommendation,
  }) = _Detail;
  const factory RecommendationsState.feedbackSubmitted({
    required String message,
  }) = _FeedbackSubmitted;
}