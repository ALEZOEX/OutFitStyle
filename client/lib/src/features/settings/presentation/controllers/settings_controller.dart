import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/states/settings_state.dart';

/// Контроллер настроек
class SettingsController extends StateNotifier<SettingsState> {
  final Future<SharedPreferences> _sharedPreferences;

  SettingsController({required Future<SharedPreferences> sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(const SettingsState());

  static const String _keyTheme = 'theme';
  static const String _keyLanguage = 'language';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyLocation = 'location_enabled';

  /// Загрузка настроек
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await _sharedPreferences;
      final settings = <String, dynamic>{
        'theme': prefs.getString(_keyTheme) ?? 'system',
        'language': prefs.getString(_keyLanguage) ?? 'ru',
        'notifications_enabled': prefs.getBool(_keyNotifications) ?? true,
        'location_enabled': prefs.getBool(_keyLocation) ?? true,
      };
      state = state.copyWith(
        isLoading: false,
        settings: settings,
      );
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
      final prefs = await _sharedPreferences;
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
      final newSettings = Map<String, dynamic>.from(state.settings)..[key] = value;
      state = state.copyWith(settings: newSettings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Получить настройку
  T getSetting<T>(String key, T defaultValue) {
    final value = state.settings[key];
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  /// Очистить все настройки
  Future<void> clearSettings() async {
    try {
      final prefs = await _sharedPreferences;
      await prefs.clear();
      state = state.copyWith(settings: {});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}