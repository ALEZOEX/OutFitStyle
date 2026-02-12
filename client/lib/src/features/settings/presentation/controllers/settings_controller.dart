import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState.initial());

  // Add methods to interact with settings
}