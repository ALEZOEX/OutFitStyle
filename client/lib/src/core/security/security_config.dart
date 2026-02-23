/// Security config с поддержкой всех платформ
/// Использует conditional imports для определения платформы
export 'security_config_io.dart' if (dart.library.html) 'security_config_web.dart';
