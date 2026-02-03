import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/home_state.dart';

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState());

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
