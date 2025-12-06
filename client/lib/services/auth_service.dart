// По умолчанию IO-реализация, для Web — web-реализация.
export 'auth_service_io.dart'
if (dart.library.html) 'auth_service_web.dart';