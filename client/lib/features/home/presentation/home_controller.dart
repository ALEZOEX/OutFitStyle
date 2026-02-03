import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/states/async_state.dart' as app_state;
import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/states/ui_states.dart';

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(HomeState());

  Future<void> loadTodayOutfit() async {
    // Логика загрузки сегодняшнего аутфита
  }

  Future<void> loadWardrobeStats() async {
    // Логика загрузки статистики гардероба
  }

  Future<void> loadRecommendations() async {
    // Логика загрузки рекомендаций
  }
}
