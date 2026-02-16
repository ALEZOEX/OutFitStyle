import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/states/settings_state.dart';

/// Контроллер настроек
class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  /// Загрузка настроек
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Implement settings loading
      throw UnimplementedError();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Обновление настройки
  Future<void> updateSetting(String key, dynamic value) async {
    try {
      final newSettings = Map<String, dynamic>.from(state.settings)..[key] = value;
      state = state.copyWith(settings: newSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}