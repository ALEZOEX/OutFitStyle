import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../local/app_database.dart';
import '../local/dao/sync_outbox_dao.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../remote/recommendations_remote_ds.dart';

class SyncWorker {
  final AppDatabase _db;
  final WardrobeRemoteDataSource _wardrobeRemote;
  final RecommendationsRemoteDataSource _recRemote;
  Timer? _periodicTimer;

  SyncWorker({
    required AppDatabase db,
    required WardrobeRemoteDataSource wardrobeRemote,
    required RecommendationsRemoteDataSource recRemote,
  })  : _db = db,
        _wardrobeRemote = wardrobeRemote,
        _recRemote = recRemote;

  Future<void> syncPendingChanges() async {
    // Получаем отложенные изменения
    final pendingChanges = await _db.syncOutboxDao.getPendingChanges();

    for (final change in pendingChanges) {
      try {
        // Выполняем синхронизацию в зависимости от типа действия
        switch (change.action) {
          case 'wardrobe_create':
            await _wardrobeRemote.create(change.payload);
            break;
          case 'wardrobe_update':
            await _wardrobeRemote.update(change.entityId, change.payload);
            break;
          case 'wardrobe_delete':
            await _wardrobeRemote.delete(change.entityId);
            break;
          case 'recommendation_create':
            await _recRemote.create(change.payload);
            break;
          case 'recommendation_update':
            await _recRemote.update(change.entityId, change.payload);
            break;
          case 'recommendation_delete':
            await _recRemote.delete(change.entityId);
            break;
        }

        // Отмечаем, что синхронизация прошла успешно
        await _db.syncOutboxDao.markAsSynced(change.id);
      } catch (e) {
        // Логируем ошибку, но не прерываем синхронизацию других элементов
        // print('Sync error for ${change.id}: $e');
      }
    }
  }

  /// Метод для однократного запуска синхронизации
  Future<void> startSync() async {
    try {
      await syncPendingChanges();
    } catch (e) {
      // Логируем ошибку
      print('Sync error: $e');
    }
  }

  /// Метод для запуска периодической синхронизации
  Future<void> startPeriodicSync() async {
    // Проверяем подключение к интернету перед синхронизацией
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // Запускаем синхронизацию каждые 5 минут при наличии подключения
      _periodicTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
        await startSync();
      });
    }
  }

  /// Метод для остановки периодической синхронизации
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}

// Класс для представления действия в очереди синхронизации
class SyncOutboxRow {
  final int id;
  final String action;
  final String entityType;
  final String entityId;
  final String payload;
  final DateTime createdAt;
  final bool synced;

  SyncOutboxRow({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.createdAt,
    required this.synced,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
        'synced': synced,
      };

  static SyncOutboxRow fromJson(Map<String, dynamic> json) => SyncOutboxRow(
        id: json['id'],
        action: json['action'],
        entityType: json['entity_type'],
        entityId: json['entity_id'],
        payload: json['payload'],
        createdAt: DateTime.parse(json['created_at']),
        synced: json['synced'] ?? false,
      );
}