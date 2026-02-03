import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/states/settings_state.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());
}
