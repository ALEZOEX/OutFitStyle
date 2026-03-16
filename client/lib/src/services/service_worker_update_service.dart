/// Service Worker Update Detection Service
///
/// Conditional export:
/// - Web: real implementation with dart:html
/// - Mobile/Desktop: stub implementation (no-op)
library;

// Conditional import based on platform
// ignore: avoid_web_libraries_in_flutter
export 'service_worker_update_service_stub.dart'
    if (dart.library.html) 'service_worker_update_service_impl.dart';
