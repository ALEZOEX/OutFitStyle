import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для доступа к текущему режиму темы
final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    return ThemeModeController();
  },
);

/// Контроллер управления темой приложения
///
/// Сохраняет выбор пользователя в SharedPreferences:
/// - Ключ: 'theme_mode'
/// - Значения: 'dark', 'light', 'system'
///
/// Тема по умолчанию: системная (автоматически от настроек устройства)
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _load();
  }

  static const String _kThemeMode = 'theme_mode';
  static const String _kValueDark = 'dark';
  static const String _kValueLight = 'light';
  static const String _kValueSystem = 'system';

  /// Загрузка сохранённой темы из SharedPreferences
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_kThemeMode);

      if (value == null) {
        // Если значение не сохранено, используем системную тему
        state = ThemeMode.system;
        return;
      }

      state = _parseThemeMode(value);
    } catch (e) {
      // При ошибке загрузки используем системную тему
      state = ThemeMode.system;
    }
  }

  /// Парсинг строкового значения в ThemeMode
  ThemeMode _parseThemeMode(String value) {
    return switch (value) {
      _kValueDark => ThemeMode.dark,
      _kValueLight => ThemeMode.light,
      _kValueSystem => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  /// Сериализация ThemeMode в строку
  String _serializeThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => _kValueDark,
      ThemeMode.light => _kValueLight,
      ThemeMode.system => _kValueSystem,
    };
  }

  /// Сохранение режима темы в SharedPreferences
  Future<void> _save(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeMode, _serializeThemeMode(mode));
    } catch (e) {
      // Игнорируем ошибку сохранения, но логируем в продакшене
      // В реальной реализации можно добавить логирование
    }
  }

  /// Установить тёмную тему
  Future<void> setDark() async {
    state = ThemeMode.dark;
    await _save(ThemeMode.dark);
  }

  /// Установить светлую тему
  Future<void> setLight() async {
    state = ThemeMode.light;
    await _save(ThemeMode.light);
  }

  /// Установить системную тему
  Future<void> setSystem() async {
    state = ThemeMode.system;
    await _save(ThemeMode.system);
  }

  /// Переключение темы (циклически: dark → light → system → dark)
  void toggle() {
    final nextMode = switch (state) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.system,
      ThemeMode.system => ThemeMode.dark,
    };
    setMode(nextMode);
  }

  /// Установить произвольный режим темы
  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _save(mode);
  }

  /// Проверка, активна ли тёмная тема
  bool get isDarkMode => state == ThemeMode.dark;

  /// Проверка, активна ли светлая тема
  bool get isLightMode => state == ThemeMode.light;

  /// Проверка, активна ли системная тема
  bool get isSystemMode => state == ThemeMode.system;
}
