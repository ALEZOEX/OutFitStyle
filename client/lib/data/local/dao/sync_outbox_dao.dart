import 'dart:math' as math;
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase> with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.db);

  Future<int> enqueue({
    required String type,
    String? entityId,
    required String payloadJson,
  }) {
    return into(syncOutbox).insert(
      SyncOutboxCompanion.insert(
        type: type,
        entityId: Value(entityId),
        payloadJson: payloadJson,
        attempts: const Value(0),
        nextAttemptAt: Value(DateTime.now()),
        lastError: const Value(null),
      ),
    );
  }

  Future<List<SyncOutboxRow>> takeDue({int limit = 20}) {
    final now = DateTime.now();
    final q = (select(syncOutbox)
          ..where((t) => t.nextAttemptAt.isSmallerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
    return q;
  }

  Future<void> markSuccess(int localId) {
    return (delete(syncOutbox)..where((t) => t.localId.equals(localId))).go();
  }

  Future<void> markFailed(int localId, String error, int attempts) {
    // backoff: 2^attempts секунд, максимум 1 час
    final delaySec = math.min(math.pow(2, attempts).toInt(), 3600);
    final next = DateTime.now().add(Duration(seconds: delaySec));

    return (update(syncOutbox)..where((t) => t.localId.equals(localId))).write(
      SyncOutboxCompanion(
        attempts: Value(attempts),
        lastError: Value(error),
        nextAttemptAt: Value(next),
      ),
    );
  }

  Stream<int> watchPendingCount() {
    final q = select(syncOutbox);
    return q.watch().map((rows) => rows.length);
  }
}