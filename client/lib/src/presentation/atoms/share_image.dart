/// ShareImage с поддержкой всех платформ
/// Использует conditional imports для определения платформы
export 'share_image_io.dart' if (dart.library.html) 'share_image_web.dart';
