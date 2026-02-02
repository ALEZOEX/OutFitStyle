import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase> with _$SyncOutboxDaoMixin {
  SyncOutboxDao(AppDatabase db) : super(db);

  // Получить все отложенные изменения
  Future<List<SyncOutboxRow>> getAll() {
    return select(syncOutbox).get();
  }

  // Получить отложенные изменения
  Future<List<SyncOutboxRow>> getPendingChanges() {
    return (select(syncOutbox)..where((tbl) => tbl.synced.equals(false))).get();
  }

  // Добавить новое действие в очередь
  Future<int> insertAction(String action, String entityType, String entityId, String payload) {
    return into(syncOutbox).insert(SyncOutboxCompanion(
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      createdAt: Value(DateTime.now()),
      synced: Value(false),
    ));
  }

  // Отметить действие как синхронизированное
  Future<void> markAsSynced(int id) {
    return (update(syncOutbox)..where((tbl) => tbl.id.equals(id)))
        .write(const SyncOutboxCompanion(synced: Value(true)));
  }

  // Удалить действие из очереди
  Future<void> removeAction(int id) {
    return (delete(syncOutbox)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Получить количество отложенных действий
  Stream<int> watchPendingCount() {
    return (selectOnly(syncOutbox)..addColumns([count(syncOutbox.id).alias('count')])
          ..where(syncOutbox.synced.equals(false)))
        .watchSingle()
        .map((row) => row.read<int>('count'));
  }

  // Очистить завершенные действия
  Future<void> cleanupCompleted() {
    return (delete(syncOutbox)..where((tbl) => tbl.synced.equals(true))).go();
  }
}