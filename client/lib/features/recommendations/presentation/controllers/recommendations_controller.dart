import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/entities/outfit_recommendation.dart';
import 'package:outfitstyle_client/domain/services/recommendations_domain_service.dart';
import 'package:outfitstyle_client/domain/states/recommendations_state.dart';

class RecommendationsController extends StateNotifier<RecommendationsState> {
  final Ref _ref;

  RecommendationsController(this._ref) : super(RecommendationsInitial());

  Future<void> loadRecommendations() async {
    state = RecommendationsLoading();
    try {
      final service = _ref.read(recommendationsDomainServiceProvider);
      final recommendations = await service.getRecentRecommendations();
      state = RecommendationsLoaded(recommendations);
    } catch (e) {
      state = RecommendationsError(e.toString());
    }
  }

  Future<void> generateRecommendation({
    required String occasion,
    required double temperature,
    required String userId,
    required String weatherCondition,
  }) async {
    try {
      final service = _ref.read(recommendationsDomainServiceProvider);
      final recommendation = await service.generateRecommendation(
        occasion: occasion,
        temperature: temperature,
        userId: userId,
        weatherCondition: weatherCondition,
      );
      state = RecommendationsGenerated(recommendation);
    } catch (e) {
      state = RecommendationsError(e.toString());
    }
  }

  Future<void> rateRecommendation(String id, double rating) async {
    try {
      final service = _ref.read(recommendationsDomainServiceProvider);
      await service.rateRecommendation(id, rating);
      // Reload recommendations to reflect the changes
      await loadRecommendations();
    } catch (e) {
      state = RecommendationsError(e.toString());
    }
  }
}