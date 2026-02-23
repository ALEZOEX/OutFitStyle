/// AuthService с поддержкой всех платформ
/// Использует conditional imports для определения платформы
export 'auth_service_io.dart' if (dart.library.html) 'auth_service_web.dart';
