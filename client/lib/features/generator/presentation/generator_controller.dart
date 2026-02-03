import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/states/ui_states.dart';

class GeneratorController extends StateNotifier<GeneratorState> {
  GeneratorController() : super(GeneratorState());

  Future<void> generateOutfit() async {
    // Логика генерации аутфита
  }

  Future<void> saveGeneratedOutfit() async {
    // Логика сохранения сгенерированного аутфита
  }
}
