import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:synchronized/synchronized.dart';

import '../../domain/repositories/i_wardrobe_repository.dart';

/// Сервис фоновой синхронизации гардероба
class WardrobeSyncService {
  final IWardrobeRepository wardrobeRepository;
  final Logger _logger;
  final Connectivity _connectivity;
  
  Timer? _syncTimer;
  final _syncLock = Lock();
  bool _isSyncing = false;

  WardrobeSyncService({
    required this.wardrobeRepository,
    Logger? logger,
    Connectivity? connectivity,
  })  : _logger = logger ?? Logger(),
        _connectivity = connectivity ?? Connectivity();

  /// Запустить периодическую синхронизацию
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _logger.i('Запуск периодической синхронизации (интервал: ${interval.inMinutes} мин)');
    
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => sync());
  }

  /// Остановить периодическую синхронизацию
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _logger.i('Периодическая синхронизация остановлена');
  }

  /// Выполнить синхронизацию
  Future<void> sync() async {
    if (_isSyncing) {
      _logger.d('Синхронизация уже выполняется, пропускаем');
      return;
    }

    await _syncLock.synchronized(() async {
      if (_isSyncing) return;
      _isSyncing = true;

      try {
        _logger.d('Начало синхронизации гардероба...');

        // Проверяем наличие соединения
        final isConnected = await _checkConnection();
        if (!isConnected) {
          _logger.d('Нет соединения, синхронизация отложена');
          return;
        }

        // Синхронизируем локальные изменения на сервер
        await _syncLocalChangesToServer();

        // Загружаем изменения с сервера
        await _syncServerChangesToLocal();

        _logger.i('Синхронизация гардероба завершена успешно');
      } catch (e, st) {
        _logger.e('Ошибка синхронизации гардероба', error: e, stackTrace: st);
      } finally {
        _isSyncing = false;
      }
    });
  }

  /// Проверить наличие подключения к интернету
  Future<bool> _checkConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.any(
        (result) => result != ConnectivityResult.none,
      );
    } catch (e) {
      _logger.w('Ошибка проверки подключения', error: e);
      return false;
    }
  }

  /// Синхронизировать локальные изменения на сервер
  Future<void> _syncLocalChangesToServer() async {
    final unsyncedItems = await wardrobeRepository.getUnsynced();
    
    if (unsyncedItems.isEmpty) {
      _logger.d('Нет несинхронизированных элементов');
      return;
    }

    _logger.d('Синхронизация ${unsyncedItems.length} несинхронизированных элементов...');

    for (final item in unsyncedItems) {
      try {
        await wardrobeRepository.updateWardrobeItem(item);
      } catch (e) {
        _logger.w('Не удалось синхронизировать элемент ${item.id}', error: e);
      }
    }
  }

  /// Синхронизировать изменения с сервера
  Future<void> _syncServerChangesToLocal() async {
    try {
      await wardrobeRepository.syncFromServer();
    } catch (e) {
      _logger.e('Ошибка загрузки изменений с сервера', error: e);
      rethrow;
    }
  }

  /// Получить статус синхронизации
  bool get isSyncing => _isSyncing;

  /// Очистить ресурсы
  void dispose() {
    stopPeriodicSync();
    _logger.d('WardrobeSyncService disposed');
  }
}
