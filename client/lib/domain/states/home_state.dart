import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/recommendation_entity.dart';
import '../entities/wardrobe_entity.dart';
import 'async_state.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(AsyncLoading<List<RecommendationRow>>())
    AsyncState<List<RecommendationRow>> todayRecommendations,
    @Default(AsyncLoading<List<WardrobeEntry>>())
    AsyncState<List<WardrobeEntry>> wardrobeStats,
    @Default(false) bool isLoading,
    String? error,
  }) = _HomeState;

  const HomeState._();
}