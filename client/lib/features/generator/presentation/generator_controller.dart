import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/generator_state.dart';

class GeneratorController extends StateNotifier<GeneratorState> {
  final Ref _ref;

  GeneratorController(this._ref) : super(const GeneratorState());

  Future<void> bootstrap() async {
    // Initialize the generator
  }

  Future<void> resetDeck() async {
    // Reset the generator deck
  }

  Future<void> setOccasion(String occasion) async {
    state = state.copyWith(occasion: occasion);
  }

  Future<void> generate() async {
    // Логика генерации аутфита
  }

  Future<void> like() async {
    // Логика лайка
  }

  Future<void> dislike() async {
    // Логика дизлайка
  }
}
