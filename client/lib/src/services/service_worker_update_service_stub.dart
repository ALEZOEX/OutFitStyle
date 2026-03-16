import 'dart:async';

class ServiceWorkerUpdateService {
  static final ServiceWorkerUpdateService _instance = ServiceWorkerUpdateService._internal();
  factory ServiceWorkerUpdateService() => _instance;
  ServiceWorkerUpdateService._internal();

  final _updateAvailableController = StreamController<bool>.broadcast();
  Stream<bool> get updateAvailable => _updateAvailableController.stream;
  bool _isUpdateAvailable = false;
  bool get isUpdateAvailable => _isUpdateAvailable;

  void initialize() {}
  void applyUpdate() {}
  void dispose() { _updateAvailableController.close(); }
}
