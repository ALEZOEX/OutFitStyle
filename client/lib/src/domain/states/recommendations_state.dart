/// Состояние рекомендаций
class RecommendationsState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> recommendations;

  const RecommendationsState({
    this.isLoading = false,
    this.error,
    this.recommendations = const [],
  });

  factory RecommendationsState.initial() => const RecommendationsState();

  RecommendationsState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? recommendations,
  }) {
    return RecommendationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      recommendations: recommendations ?? this.recommendations,
    );
  }
}