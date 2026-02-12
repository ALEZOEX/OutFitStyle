import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/generator_state.dart';

class GeneratorController extends StateNotifier<GeneratorState> {
  final Ref _ref;

  GeneratorController(this._ref) : super(const GeneratorState.initial());

  // Add methods to interact with outfit generator
}