/// Platform flags с поддержкой всех платформ включая Web
/// Использует conditional imports для определения платформы

export 'platform_flags_io.dart' if (dart.library.html) 'platform_flags_web.dart';
