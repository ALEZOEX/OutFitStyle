import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/wardrobe_state.dart';
import '../../../domain/services/wardrobe_domain_service.dart';

class WardrobeController extends StateNotifier<WardrobeState> {
  final Ref _ref;

  WardrobeController(this._ref) : super(const WardrobeState.initial());

  // Add methods to interact with wardrobe
}