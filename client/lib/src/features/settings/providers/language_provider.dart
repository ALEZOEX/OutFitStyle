import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Провайдер для текущего языка
final currentLanguageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('ru') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('app_language') ?? 'ru';
    state = savedLanguage;
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', languageCode);
    state = languageCode;
  }
}

/// Провайдер для авто-определения языка
final autoLanguageProvider = StateNotifierProvider<AutoLanguageNotifier, bool>((ref) {
  return AutoLanguageNotifier();
});

class AutoLanguageNotifier extends StateNotifier<bool> {
  AutoLanguageNotifier() : super(true) {
    _loadAutoLanguage();
  }

  Future<void> _loadAutoLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final autoLanguage = prefs.getBool('auto_language') ?? true;
    state = autoLanguage;
  }

  Future<void> setAutoLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_language', value);
    state = value;
  }
}
