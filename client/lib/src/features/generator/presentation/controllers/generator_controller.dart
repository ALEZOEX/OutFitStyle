import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/generator_state.dart';

/// Контроллер генератора нарядов
class GeneratorController extends StateNotifier<GeneratorState> {
  GeneratorController() : super(const GeneratorState());

  /// Генерация наряда на основе параметров
  Future<void> generateOutfit({
    required double latitude,
    required double longitude,
    required String occasion,
    required List<String> preferredStyles,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement outfit generation
      throw UnimplementedError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}