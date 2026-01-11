import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = false;
  Timer? _syncTimer;

  Future<void> initialize() async {
    await _updateConnectivityStatus();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        if (result.isNotEmpty) {
          _updateConnectivityStatus(result.first);
        }
      },
    );
    
    // Start periodic sync when online
    _startPeriodicSync();
  }

  Future<void> _updateConnectivityStatus([ConnectivityResult? result]) async {
    if (result == null) {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.isNotEmpty) {
        result = connectivityResult.first;
      } else {
        result = ConnectivityResult.none;
      }
    }

    _isOnline = result != ConnectivityResult.none;

    if (_isOnline) {
      // Sync immediately when connection restored
      await _performSync();
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_isOnline) {
        await _performSync();
      }
    });
  }

  Future<void> _performSync() async {
    try {
      // Sync user preferences
      await _syncUserPreferences();
      
      // Sync wardrobe items
      await _syncWardrobe();
      
      // Sync recommendations
      await _syncRecommendations();
      
      // Sync feedback
      await _syncFeedback();
    } catch (e) {
      // Log error but continue with other sync operations
    }
  }

  Future<void> _syncUserPreferences() async {
    // Implementation for syncing user preferences
  }

  Future<void> _syncWardrobe() async {
    // Implementation for syncing wardrobe items
  }

  Future<void> _syncRecommendations() async {
    // Implementation for syncing recommendations
  }

  Future<void> _syncFeedback() async {
    // Implementation for syncing feedback
  }

  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}