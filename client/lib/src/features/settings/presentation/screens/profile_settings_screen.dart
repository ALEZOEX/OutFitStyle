/// ProfileSettingsScreen с поддержкой всех платформ
/// Использует conditional imports для определения платформы
export 'profile_settings_screen_io.dart' if (dart.library.html) 'profile_settings_screen_web.dart';
