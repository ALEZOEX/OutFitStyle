// Stub implementation for non-web platforms
// Service Worker доступен только в web-браузерах

import 'dart:async';

/// Service Worker Update Detection Service (Stub for mobile)
///
/// Works only on web platform.
class ServiceWorkerUpdateService {
  static final ServiceWorkerUpdateService _instance = ServiceWorkerUpdateService._internal();
  factory ServiceWorkerUpdateService() => _instance;
  ServiceWorkerUpdateService._internal();

  final _updateAvailableController = StreamController<bool>.broadcast();
  Stream<bool> get updateAvailable => _updateAvailableController.stream;

  bool _isUpdateAvailable = false;
  bool get isUpdateAvailable => _isUpdateAvailable;

  /// Initialize Service Worker update detection (no-op on mobile)
  void initialize() {
    // No-op on mobile
  }

  /// Apply the update by reloading the page (no-op on mobile)
  void applyUpdate() {
    // No-op on mobile
  }

  /// Dispose resources
  void dispose() {
    _updateAvailableController.close();
  }
}
