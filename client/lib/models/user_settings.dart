import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  String userId;
  String name;
  String email;
  String? avatarUrl;
  
  // Preferences
  String temperatureSensitivity; // 'cold', 'normal', 'warm'
  String stylePreference; // 'casual', 'business', 'sporty', 'elegant'
  String ageRange; // '18-25', '25-35', '35-45', '45+'
  List<String> preferredCategories;
  
  // App settings
  bool notificationsEnabled;
  bool autoSaveOutfits;
  String temperatureUnit; // 'celsius', 'fahrenheit'
  String language; // 'ru', 'en'

  UserSettings({
    required this.userId,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.temperatureSensitivity = 'normal',
    this.stylePreference = 'casual',
    this.ageRange = '25-35',
    this.preferredCategories = const [],
    this.notificationsEnabled = true,
    this.autoSaveOutfits = false,
    this.temperatureUnit = 'celsius',
    this.language = 'ru',
  });

  // Сохранение в SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_avatar', avatarUrl ?? '');
    await prefs.setString('temp_sensitivity', temperatureSensitivity);
    await prefs.setString('style_preference', stylePreference);
    await prefs.setString('age_range', ageRange);
    await prefs.setStringList('preferred_categories', preferredCategories);
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('auto_save_outfits', autoSaveOutfits);
    await prefs.setString('temperature_unit', temperatureUnit);
    await prefs.setString('language', language);
  }

  // Загрузка из SharedPreferences
  static Future<UserSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSettings(
      userId: prefs.getString('user_id') ?? '1',
      name: prefs.getString('user_name') ?? 'Пользователь',
      email: prefs.getString('user_email') ?? 'user@example.com',
      avatarUrl: prefs.getString('user_avatar'),
      temperatureSensitivity: prefs.getString('temp_sensitivity') ?? 'normal',
      stylePreference: prefs.getString('style_preference') ?? 'casual',
      ageRange: prefs.getString('age_range') ?? '25-35',
      preferredCategories: prefs.getStringList('preferred_categories') ?? [],
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      autoSaveOutfits: prefs.getBool('auto_save_outfits') ?? false,
      temperatureUnit: prefs.getString('temperature_unit') ?? 'celsius',
      language: prefs.getString('language') ?? 'ru',
    );
  }

  // Очистка (при удалении аккаунта)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'email': email,
    'temperature_sensitivity': temperatureSensitivity,
    'style_preference': stylePreference,
    'age_range': ageRange,
    'preferred_categories': preferredCategories,
  };
}