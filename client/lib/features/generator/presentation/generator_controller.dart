import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/states/async_state.dart' as app_state;
import '../../../domain/entities/recommendation_entity.dart';
import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/states/ui_states.dart';

final generatorControllerProvider =
    StateNotifierProvider<GeneratorController, GeneratorState>(
  GeneratorController.new,
);

class GeneratorController extends StateNotifier<GeneratorState> {
  GeneratorController() : super(GeneratorState());

  Future<void> generateOutfit() async {
    // Логика генерации аутфита
  }

  Future<void> saveGeneratedOutfit() async {
    // Логика сохранения сгенерированного аутфита
  }
}