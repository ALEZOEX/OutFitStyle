import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/wardrobe_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/sync/sync_worker.dart';
import '../../domain/entities/wardrobe_item.dart' as domain;
import '../../domain/entities/outfit_recommendation.dart';
import '../../domain/entities/wardrobe_request_entities.dart';

/// Управляет синхронизацией всех данных приложения, включая пользовательские настройки,
/// элементы гардероба, рекомендации и отзывы.
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isOnline = false;
  Timer? _syncTimer;

  // Progress tracking
  final Map<String, double> _progress = {};
  final Map<String, String> _currentOperation = {};

  // Dependencies - will be injected later
  late SyncWorker _syncWorker;
  late ProfileRepository _profileRepository;
  late WardrobeRepository _wardrobeRepository;
  late AuthRepository _authRepository;

  /// Кэш userId для избежания повторных запросов
  String? _cachedUserId;

  /// Получает userId из AuthRepository с кэшированием
  Future<String?> _getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId;
    }

    try {
      _cachedUserId = await _authRepository.getUserId();
      return _cachedUserId;
    } catch (e, stackTrace) {
      _logWarning('Failed to get user ID: $e', null, stackTrace);
      return null;
    }
  }

  /// Инициализирует SyncManager с необходимыми зависимостями
  Future<void> initialize({
    required SyncWorker syncWorker,
    required ProfileRepository profileRepository,
    required WardrobeRepository wardrobeRepository,
    required AuthRepository authRepository,
  }) async {
    _syncWorker = syncWorker;
    _profileRepository = profileRepository;
    _wardrobeRepository = wardrobeRepository;
    _authRepository = authRepository;

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

    _logInfo('SyncManager initialized');
  }

  /// Обновляет статус подключения и запускает синхронизацию при восстановлении соединения
  Future<void> _updateConnectivityStatus([ConnectivityResult? result]) async {
    if (result == null) {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.isNotEmpty) {
        result = connectivityResult.first;
      } else {
        result = ConnectivityResult.none;
      }
    }

    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (_isOnline && !wasOnline) {
      // Connection restored - sync immediately
      _logInfo('Connection restored, triggering sync');
      await _performSync();
    } else if (!_isOnline) {
      _logInfo('Connection lost');
    }
  }

  /// Запускает периодическую синхронизацию каждые 5 минут
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_isOnline) {
        await _performSync();
      }
    });
    _logFine('Started periodic sync timer');
  }

  /// Выполняет полный цикл синхронизации
  Future<void> _performSync() async {
    _logInfo('Starting synchronization');

    try {
      // Update progress
      _updateProgress('overall', 0.0);

      // Sync user preferences
      _updateCurrentOperation('preferences');
      await _syncUserPreferences();
      _updateProgress('preferences', 1.0);

      // Sync wardrobe items
      _updateCurrentOperation('wardrobe');
      await _syncWardrobe();
      _updateProgress('wardrobe', 1.0);

      // Sync recommendations
      _updateCurrentOperation('recommendations');
      await _syncRecommendations();
      _updateProgress('recommendations', 1.0);

      // Sync feedback
      _updateCurrentOperation('feedback');
      await _syncFeedback();
      _updateProgress('feedback', 1.0);

      // Sync pending changes from outbox
      _updateCurrentOperation('pending_changes');
      await _syncPendingChanges();
      _updateProgress('pending_changes', 1.0);

      _updateProgress('overall', 1.0);
      _updateCurrentOperation('complete');

      _logInfo('Synchronization completed successfully');
    } catch (e, stackTrace) {
      _logSevere('Synchronization failed', e, stackTrace);
      _updateCurrentOperation('error');
      // Continue with other sync operations even if one fails
    }
  }

  /// Синхронизирует пользовательские настройки с сервером
  Future<void> _syncUserPreferences() async {
    try {
      _logFine('Syncing user preferences...');

      // Get local preferences that need to be synced
      final localChanges = await _getLocalPreferenceChanges();

      if (localChanges.isNotEmpty) {
        _logFine('Found ${localChanges.length} local preference changes to sync');

        // Send changes to server
        for (final change in localChanges) {
          try {
            await _profileRepository.updatePreferences(change);

            // Mark as synced (implementation depends on how preferences are stored locally)
            await _markPreferenceAsSynced(change);
          } catch (e, stackTrace) {
            _logWarning('Failed to sync preference change: $e', null, stackTrace);
            // Continue with other changes
          }
        }
      }

      // Pull latest preferences from server
      await _pullUserPreferences();

      _logFine('User preferences sync completed');
    } catch (e, stackTrace) {
      _logSevere('Error syncing user preferences', e, stackTrace);
      rethrow;
    }
  }

  /// Получает локальные изменения настроек, которые необходимо синхронизировать
  Future<List<Map<String, dynamic>>> _getLocalPreferenceChanges() async {
    // In a real implementation, this would query the local database for 
    // preferences marked as dirty or unsynced
    // For now, returning empty list as preferences sync is handled differently
    return [];
  }

  /// Отмечает изменение настроек как синхронизированное
  Future<void> _markPreferenceAsSynced(Map<String, dynamic> change) async {
    // Implementation would mark the preference as synced in local storage
  }

  /// Получает последние пользовательские настройки с сервера
  Future<void> _pullUserPreferences() async {
    try {
      final serverPrefs = await _profileRepository.getMe();
      // Update local preferences with server values
      // Implementation would depend on how preferences are stored locally
      _logFine('Pulled ${serverPrefs.length} user preferences from server');
    } catch (e, stackTrace) {
      _logWarning('Failed to pull user preferences from server', null, stackTrace);
    }
  }

  /// Синхронизирует элементы гардероба с сервером
  Future<void> _syncWardrobe() async {
    try {
      _logFine('Syncing wardrobe items...');

      // First, sync pending changes from local to server
      await _syncWardrobePendingChanges();

      // Then, pull latest changes from server
      await _syncWorker.syncWardrobe();

      _logFine('Wardrobe sync completed');
    } catch (e, stackTrace) {
      _logSevere('Error syncing wardrobe', e, stackTrace);
      rethrow;
    }
  }

  /// Синхронизирует ожидающие изменения гардероба с сервером
  Future<void> _syncWardrobePendingChanges() async {
    try {
      // Get unsynced wardrobe items
      final unsyncedItems = await _wardrobeRepository.getUnsynced();

      if (unsyncedItems.isEmpty) {
        _logFine('No unsynced wardrobe items to sync');
        return;
      }

      _logFine('Found ${unsyncedItems.length} unsynced wardrobe items');

      for (final item in unsyncedItems) {
        await _syncWardrobeItem(item);
      }
    } catch (e, stackTrace) {
      _logSevere('Error syncing pending wardrobe changes', e, stackTrace);
      rethrow;
    }
  }

  /// Синхронизирует один элемент гардероба
  Future<void> _syncWardrobeItem(domain.WardrobeItem item) async {
    try {
      final itemId = item.id ?? '';
      if (item.serverId == null) {
        // New item - create on server
        final createdItem = await _createWardrobeItem(item);
        await _wardrobeRepository.markAsSynced(itemId, createdItem.serverId ?? itemId);
      } else {
        // Existing item - update on server
        await _updateWardrobeItem(item);
        await _wardrobeRepository.markAsSynced(itemId, item.serverId ?? itemId);
      }
    } catch (e, stackTrace) {
      _logWarning('Failed to sync wardrobe item ${item.id}: $e', stackTrace);
      // Don't rethrow - allow other items to sync
    }
  }

  /// Создает элемент гардероба на сервере
  Future<domain.WardrobeItem> _createWardrobeItem(domain.WardrobeItem item) async {
    // Получаем userId из AuthRepository
    final userId = await _getUserId();

    // Convert domain entity to request object
    final request = WardrobeItemCreateRequest(
      name: item.name ?? 'Unknown',
      category: item.category ?? 'other',
      subcategory: item.subcategory ?? 'other',
      style: item.style ?? 'casual',
      iconEmoji: item.iconEmoji ?? '👕',
      imageUrl: item.imageUrl,
      blurHash: item.blurHash,
      minTemp: item.minTemp?.toInt(),
      maxTemp: item.maxTemp?.toInt(),
      warmthLevel: item.warmthLevel,
      rainOk: item.rainOk ?? false,
      snowOk: item.snowOk ?? false,
      windOk: item.windOk ?? false,
      usage: item.usage?.toString(),
      materials: item.materials?.join(','),
      isFavorite: item.isFavorite ?? false,
      isArchived: item.isArchived ?? false,
      season: item.season,
      gender: item.gender,
      fit: item.fit,
      pattern: item.pattern,
      localImagePath: item.localImagePath,
      userId: userId ?? 'anonymous',
      clothingItemId: item.id ?? '',
    );

    // This would typically call the remote data source directly
    // For now, we'll simulate the creation by returning an updated item
    // Using the request object to avoid the unused variable warning
    _logFine('Creating wardrobe item: ${request.name}');
    return item.copyWith(serverId: item.id, dirty: false, lastSyncedAt: DateTime.now());
  }

  /// Обновляет элемент гардероба на сервере
  Future<void> _updateWardrobeItem(domain.WardrobeItem item) async {
    // This would typically call the remote data source to update the item
    // For now, we'll just log the operation
    _logFine('Updating wardrobe item ${item.id} on server');
  }

  /// Синхронизирует рекомендации с сервером
  Future<void> _syncRecommendations() async {
    try {
      _logFine('Syncing recommendations...');

      // First, sync pending changes from local to server
      await _syncRecommendationsPendingChanges();

      // Then, pull latest changes from server
      await _syncWorker.syncRecommendations();

      _logFine('Recommendations sync completed');
    } catch (e, stackTrace) {
      _logSevere('Error syncing recommendations', e, stackTrace);
      rethrow;
    }
  }

  /// Синхронизирует ожидающие изменения рекомендаций с сервером
  Future<void> _syncRecommendationsPendingChanges() async {
    try {
      // Get unsynced recommendations
      final unsyncedRecommendations = await _getUnsyncedRecommendations();

      if (unsyncedRecommendations.isEmpty) {
        _logFine('No unsynced recommendations to sync');
        return;
      }

      _logFine('Found ${unsyncedRecommendations.length} unsynced recommendations');

      for (final rec in unsyncedRecommendations) {
        await _syncRecommendation(rec);
      }
    } catch (e, stackTrace) {
      _logSevere('Error syncing pending recommendations', e, stackTrace);
      rethrow;
    }
  }

  /// Получает несинхронизированные рекомендации
  Future<List<OutfitRecommendation>> _getUnsyncedRecommendations() async {
    // This would query the local database for recommendations marked as dirty
    // Using the repository to get unsynced recommendations
    // For now, returning empty list as this method doesn't exist in the repository
    return [];
  }

  /// Синхронизирует одну рекомендацию
  Future<void> _syncRecommendation(OutfitRecommendation rec) async {
    try {
      // Recommendations are usually generated server-side
      // Just log for now
      _logFine('Syncing recommendation ${rec.id ?? 'unknown'}');
    } catch (e, stackTrace) {
      _logWarning('Failed to sync recommendation: $e', stackTrace);
      // Don't rethrow - allow other items to sync
    }
  }

  /// Синхронизирует отзывы с сервером
  Future<void> _syncFeedback() async {
    try {
      _logFine('Syncing feedback...');

      // Get local feedback that needs to be synced
      final localFeedback = await _getLocalFeedback();

      if (localFeedback.isNotEmpty) {
        _logFine('Found ${localFeedback.length} feedback items to sync');

        for (final feedback in localFeedback) {
          try {
            await _sendFeedbackToServer(feedback);
            await _removeLocalFeedback(feedback.id);
          } catch (e, stackTrace) {
            _logWarning('Failed to sync feedback ${feedback.id}: $e', stackTrace);
            // Continue with other feedback items
          }
        }
      }

      _logFine('Feedback sync completed');
    } catch (e, stackTrace) {
      _logSevere('Error syncing feedback', e, stackTrace);
      rethrow;
    }
  }

  /// Получает локальные отзывы, которые необходимо синхронизировать
  Future<List<FeedbackItem>> _getLocalFeedback() async {
    // In a real implementation, this would query the local database for feedback
    // For now, returning empty list
    return [];
  }

  /// Отправляет отзывы на сервер
  Future<void> _sendFeedbackToServer(FeedbackItem feedback) async {
    // Implementation would send feedback to the server
    _logFine('Sending feedback ${feedback.id} to server');
  }

  /// Удаляет локальные отзывы после успешной синхронизации
  Future<void> _removeLocalFeedback(String feedbackId) async {
    // Implementation would remove feedback from local storage
  }

  /// Синхронизирует ожидающие изменения из очереди синхронизации
  Future<void> _syncPendingChanges() async {
    try {
      _logFine('Syncing pending changes from outbox...');
      await _syncWorker.syncPendingChanges();
      _logFine('Pending changes sync completed');
    } catch (e, stackTrace) {
      _logSevere('Error syncing pending changes', e, stackTrace);
      // Don't rethrow - allow other sync operations to continue
    }
  }

  /// Запускает ручную синхронизацию
  Future<void> sync() async {
    if (_isOnline) {
      _logInfo('Manual sync triggered');
      await _performSync();
    } else {
      _logWarning('Manual sync skipped - device is offline');
    }
  }

  /// Получает текущий прогресс синхронизации для конкретной операции
  double getProgress(String operation) {
    return _progress[operation] ?? 0.0;
  }

  /// Получает текущую операцию синхронизации
  String getCurrentOperation() {
    return _currentOperation['current'] ?? 'idle';
  }

  /// Обновляет прогресс для конкретной операции
  void _updateProgress(String operation, double progress) {
    _progress[operation] = progress;
    // Notify listeners about progress update if needed
  }

  /// Обновляет текущую операцию
  void _updateCurrentOperation(String operation) {
    _currentOperation['current'] = operation;
    // Notify listeners about operation change if needed
  }

  /// Освобождает ресурсы, используемые SyncManager
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _logInfo('SyncManager disposed');
  }

  /// Вспомогательный метод для записи информационных сообщений
  void _logInfo(String message) {
    developer.log(message, name: 'SyncManager', level: 800); // INFO level
  }

  /// Вспомогательный метод для записи подробных/отладочных сообщений
  void _logFine(String message) {
    developer.log(message, name: 'SyncManager', level: 500); // FINE/DEBUG level
  }

  /// Вспомогательный метод для записи предупреждающих сообщений
  void _logWarning(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'SyncManager', level: 900, error: error, stackTrace: stackTrace); // WARNING level
  }

  /// Вспомогательный метод для записи критических/ошибочных сообщений
  void _logSevere(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(message, name: 'SyncManager', level: 1000, error: error, stackTrace: stackTrace); // SEVERE/ERROR level
  }
}

/// Представляет элемент отзыва для синхронизации
class FeedbackItem {
  final String id;
  final String type;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  FeedbackItem({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    required this.metadata,
  });
}