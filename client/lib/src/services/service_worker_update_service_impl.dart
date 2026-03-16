import 'dart:async';
import 'package:flutter/foundation.dart';

// Import dart:html only for web builds
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Service Worker Update Detection Service
///
/// Validates: Requirements 2.4
///
/// This service monitors Service Worker updates and provides
/// notifications when a new version is available.
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
    html.document.onVisibilityChange.listen((_) {
      if (!html.document.hidden!) {
        debugPrint('ServiceWorkerUpdateService: Page visible, checking for updates');
        _checkForUpdates();
      }
    });

    // Initial check
    _checkForUpdates();
  }

  /// Check for Service Worker updates
  Future<void> _checkForUpdates() async {
    if (!kIsWeb) return;

    try {
      final serviceWorker = html.window.navigator.serviceWorker;
      if (serviceWorker == null) return;

      final registration = await serviceWorker.getRegistration();
      if (registration != null) {
        debugPrint('ServiceWorkerUpdateService: Checking for updates...');
        await registration.update();

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
    if (!kIsWeb) return;

    debugPrint('ServiceWorkerUpdateService: Applying update, reloading page...');
    html.window.location.reload();
  }

  /// Dispose resources
  void dispose() {
    _updateAvailableController.close();
  }
}
