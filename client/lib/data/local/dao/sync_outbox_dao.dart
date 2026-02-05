import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.db);

  // Получить все отложенные изменения
  Future<List<SyncOutboxData>> getAll() {
    return select(syncOutbox).get();
  }

  // Получить отложенные изменения
  Future<List<SyncOutboxData>> getPendingChanges() {
    return (select(syncOutbox)..where((tbl) => tbl.synced.equals(false))).get();
  }

  // Добавить новое действие в очередь
  Future<int> insertAction(
      String action, String entityType, String entityId, String payload) {
    return into(syncOutbox).insert(SyncOutboxCompanion.insert(
      action: action,
      entityType: entityType,
      entityId: entityId,
      payload: payload,
      createdAt: DateTime.now(),
      synced: false,
    ));
  }

  // Отметить действие как синхронизированное
  Future<void> markAsSynced(int id) {
    return (update(syncOutbox)..where((tbl) => tbl.id.equals(id)))
        .write(const SyncOutboxCompanion(
          synced: Value(true),
        ));
  }

  // Удалить действие из очереди
  Future<void> removeAction(int id) {
    return (delete(syncOutbox)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Получить количество отложенных действий
  Stream<int> watchPendingCount() {
    return (selectOnly(syncOutbox)
          ..addColumns([syncOutbox.id.count()])
          ..where(syncOutbox.synced.equals(false)))
        .watchSingle()
        .map((row) => row.read<int>(syncOutbox.id.count()) ?? 0);
  }

  // Очистить завершенные действия
  Future<void> cleanupCompleted() {
    return (delete(syncOutbox)..where((tbl) => tbl.synced.equals(true))).go();
  }
}
