import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/wardrobe_entity.dart';
import '../../../domain/entities/wardrobe_request_entities.dart';
import '../../../domain/states/ui_states.dart';

class WardrobeController extends StateNotifier<WardrobeState> {
  WardrobeController(Ref ref) : super(WardrobeState());
}
