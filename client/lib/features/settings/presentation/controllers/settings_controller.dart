import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/states/settings_state.dart';

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(SettingsInitial());

  void toggleDarkMode(bool enabled) {
    // In a real implementation, we would persist this setting
    state = SettingsUpdated({'darkMode': enabled});
  }

  void updateLanguage(String languageCode) {
    // In a real implementation, we would persist this setting
    state = SettingsUpdated({'language': languageCode});
  }
}