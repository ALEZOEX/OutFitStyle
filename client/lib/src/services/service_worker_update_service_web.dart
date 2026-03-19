import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class ServiceWorkerUpdateService {
  static final ServiceWorkerUpdateService _instance =
      ServiceWorkerUpdateService._internal();
  factory ServiceWorkerUpdateService() => _instance;
  ServiceWorkerUpdateService._internal();

  final _updateAvailableController = StreamController<bool>.broadcast();
  Stream<bool> get updateAvailable => _updateAvailableController.stream;
  bool _isUpdateAvailable = false;
  bool get isUpdateAvailable => _isUpdateAvailable;
  Timer? _timer;

  void initialize() {
    debugPrint('ServiceWorkerUpdateService: Initializing update detection');
    _timer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _checkForUpdates(),
    );
    html.document.onVisibilityChange.listen((_) {
      if (html.document.visibilityState == 'visible') {
        debugPrint(
          'ServiceWorkerUpdateService: Page visible, checking for updates',
        );
        _checkForUpdates();
      }
    });
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final sw = html.window.navigator.serviceWorker;
      final reg = await sw?.getRegistration();
      if (reg != null && reg.waiting != null) {
        await reg.update();
        _isUpdateAvailable = true;
        _updateAvailableController.add(true);
        debugPrint('ServiceWorkerUpdateService: Update available!');
      }
    } catch (e) {
      debugPrint('ServiceWorkerUpdateService: Error checking updates: $e');
    }
  }

  void applyUpdate() {
    debugPrint('ServiceWorkerUpdateService: Applying update');
    html.window.location.reload();
  }

  void dispose() {
    _timer?.cancel();
    _updateAvailableController.close();
  }
}
