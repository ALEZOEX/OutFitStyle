import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [WardrobeEntries])
class WardrobeDao extends DatabaseAccessor<AppDatabase> with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  Stream<List<WardrobeEntry>> watchAll({bool includeArchived = false}) {
    final q = select(wardrobeEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    if (!includeArchived) {
      q.where((t) => t.isArchived.equals(false));
    }
    return q.watch();
  }

  Future<void> upsertMany(List<WardrobeEntriesCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(wardrobeEntries, rows);
    });
  }

  Future<void> setFavorite(String id, bool value) {
    return (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        isFavorite: Value(value),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setArchived(String id, bool value) {
    return (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        isArchived: Value(value),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementWear(String id) async {
    final row = await (select(wardrobeEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;

    await (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        wearCount: Value(row.wearCount + 1),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<WardrobeEntry>> findMissingLocalImages({int limit = 30}) {
    final q = (select(wardrobeEntries)
          ..where((t) => t.imageUrl.isNotNull()
              & t.imageUrl.equals('').not()
              & t.localImagePath.isNull())
          ..limit(limit))
        .get();
    return q;
  }

  Future<void> setLocalImagePath(String id, String path) {
    return (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        localImagePath: Value(path),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}