// По умолчанию используем IO-реализацию, а если платформа — Web, то web-реализацию.
export 'auth_service_io.dart'
if (dart.library.html) 'auth_service_web.dart';