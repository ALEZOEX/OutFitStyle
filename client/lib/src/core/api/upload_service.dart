/// UploadService с поддержкой всех платформ
/// Использует conditional imports для определения платформы
export 'upload_service_io.dart' if (dart.library.html) 'upload_service_web.dart';
