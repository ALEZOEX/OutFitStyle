import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/recommendation_entity.dart';
import '../entities/wardrobe_entity.dart';
import 'async_state.dart';

part 'ui_states.freezed.dart';

@freezed
class RecommendationsState with _$RecommendationsState {
  const factory RecommendationsState({
    @Default(AsyncLoading<List<RecommendationRow>>())
    AsyncState<List<RecommendationRow>> recommendations,
    @Default(false) bool isLoading,
    String? error,
  }) = _RecommendationsState;
}

@freezed
class WardrobeState with _$WardrobeState {
  const factory WardrobeState({
    @Default(AsyncLoading<List<WardrobeEntry>>())
    AsyncState<List<WardrobeEntry>> wardrobeItems,
    @Default(false) bool isLoading,
    String? error,
  }) = _WardrobeState;
}

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
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    String? error,
  }) = _SettingsState;
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? error,
  }) = _AuthState;
}

@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentStep,
    @Default(false) bool isComplete,
    @Default(false) bool isLoading,
    String? error,
  }) = _OnboardingState;
}

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(AsyncLoading<Map<String, dynamic>>())
    AsyncState<Map<String, dynamic>> profileData,
    @Default(false) bool isLoading,
    String? error,
  }) = _ProfileState;
}
