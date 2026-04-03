import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/states/wardrobe_state.dart';

class WardrobeController extends StateNotifier<WardrobeState> {
  final Ref _ref;

  WardrobeController(this._ref) : super(const WardrobeInitial());

  // Add methods to interact with wardrobe
}
