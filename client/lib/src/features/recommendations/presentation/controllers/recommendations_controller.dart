import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/recommendations_state.dart';
import '../../../domain/services/recommendations_domain_service.dart';

class RecommendationsController extends StateNotifier<RecommendationsState> {
  final Ref _ref;

  RecommendationsController(this._ref) : super(const RecommendationsState.initial());

  // Add methods to interact with recommendations
}