import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/states/ui_states.dart';

class RecommendationsController extends StateNotifier<RecommendationsState> {
  RecommendationsController(Ref ref) : super(RecommendationsState());
}
