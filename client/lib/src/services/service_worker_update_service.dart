import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';

/// Service Worker Update Detection Service
///
/// Validates: Requirements 2.4
///
/// This service monitors Service Worker updates and provides
/// notifications when a new version is available.
class ServiceWorkerUpdateService {
  static final ServiceWorkerUpdateService _instance = ServiceWorkerUpdateService._internal();
  factory ServiceWorkerUpdateService() => _instance;
  ServiceWorkerUpdateService._internal();

  final _updateAvailableController = StreamController<bool>.broadcast();
  Stream<bool> get updateAvailable => _updateAvailableController.stream;

  bool _isUpdateAvailable = false;
  bool get isUpdateAvailable => _isUpdateAvailable;

  /// Initialize Service Worker update detection
  void initialize() {
    if (!kIsWeb) {
      debugPrint('ServiceWorkerUpdateService: Not running on web, skipping initialization');
      return;
    }

    debugPrint('ServiceWorkerUpdateService: Initializing update detection');

    // Check for updates periodically
    Timer.periodic(const Duration(seconds: 60), (_) {
      _checkForUpdates();
    });

    // Check for updates when page becomes visible
    web.document.addEventListener('visibilitychange', ((web.Event _) {
      if (!web.document.hidden) {
        debugPrint('ServiceWorkerUpdateService: Page visible, checking for updates');
        _checkForUpdates();
      }
    }) as web.EventListener);

    // Initial check
    _checkForUpdates();
  }

  /// Check for Service Worker updates
  Future<void> _checkForUpdates() async {
    try {
      final registration = await web.window.navigator.serviceWorker.getRegistration().toDart;
      if (registration != null) {
        debugPrint('ServiceWorkerUpdateService: Checking for updates...');
        await registration.update().toDart;

        // Check if there's a waiting Service Worker
        if (registration.waiting != null) {
          debugPrint('ServiceWorkerUpdateService: Update available (waiting Service Worker)');
          _isUpdateAvailable = true;
          _updateAvailableController.add(true);
        }
      }
    } catch (e) {
      debugPrint('ServiceWorkerUpdateService: Error checking for updates: $e');
    }
  }

  /// Apply the update by reloading the page
  void applyUpdate() {
    debugPrint('ServiceWorkerUpdateService: Applying update, reloading page...');
    web.window.location.reload();
  }

  /// Dispose resources
  void dispose() {
    _updateAvailableController.close();
  }
}
