import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../domain/entities/wardrobe_entity.dart' as domain;

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [WardrobeEntries])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  Stream<List<domain.WardrobeEntry>> watchAll() {
    final q = select(wardrobeEntries).watch();
    return q.map((rows) => rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList());
  }

  Stream<domain.WardrobeEntry?> watchById(String id) {
    final q = (select(wardrobeEntries)..where((t) => t.id.equals(id))).watchSingleOrNull();
    return q.map((row) => row != null ? domain.WardrobeEntry.fromDbEntity(row) : null);
  }

  Future<domain.WardrobeEntry?> getById(String id) async {
    final row = await (select(wardrobeEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? domain.WardrobeEntry.fromDbEntity(row) : null;
  }

  Future<void> upsertOne(WardrobeEntriesCompanion companion) {
    return into(wardrobeEntries).insertOnConflictUpdate(companion);
  }

  Future<void> upsertMany(List<WardrobeEntriesCompanion> companions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(wardrobeEntries, companions);
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

  Future<void> incrementWearCount(String id) {
    return customUpdate(
      'UPDATE wardrobe_entries SET wear_count = wear_count + 1, last_worn_at = ? WHERE id = ?',
      variables: [
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
    );
  }

  Future<void> insertOne(WardrobeEntriesCompanion companion) {
    return into(wardrobeEntries).insert(companion);
  }

  Future<void> updateOne(WardrobeEntriesCompanion companion) {
    // Для обновления нужен ID
    if (companion.id.present) {
      return (update(wardrobeEntries)..where((t) => t.id.equals(companion.id.value))).write(companion);
    }
    throw Exception('ID must be present for update operation');
  }

  Future<void> deleteById(String id) {
    return (delete(wardrobeEntries)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<domain.WardrobeEntry>> watchByCategory(String category) {
    final q = (select(wardrobeEntries)
          ..where((t) => t.category.equals(category)))
        .watch();
    return q.map((rows) => rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList());
  }

  // Получить все элементы (однократно)
  Future<List<domain.WardrobeEntry>> getAll() async {
    final rows = await select(wardrobeEntries).get();
    return rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList();
  }

  // Получить элементы по категориям
  Future<List<domain.WardrobeEntry>> getByCategories(List<String> categories) async {
    final rows = await (select(wardrobeEntries)
          ..where((t) => t.category.isIn(categories))
          ..where((t) => t.isArchived.equals(false)))
        .get();
    return rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList();
  }

  // Получить элементы по сезону
  Stream<List<domain.WardrobeEntry>> watchBySeason(String season) {
    final q = (select(wardrobeEntries)
          ..where((t) => t.season.equals(season))
          ..where((t) => t.isArchived.equals(false)))
        .watch();
    return q.map((rows) => rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList());
  }

  // Получить элементы по температуре
  Future<List<domain.WardrobeEntry>> getByTemperature(int temperature) async {
    final rows = await (select(wardrobeEntries)
          ..where((t) => t.minTemp.isSmallerOrEqualValue(temperature))
          ..where((t) => t.maxTemp.isBiggerOrEqualValue(temperature))
          ..where((t) => t.isArchived.equals(false)))
        .get();
    return rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList();
  }

  // Получить избранные элементы
  Stream<List<domain.WardrobeEntry>> watchFavorites() {
    final q = (select(wardrobeEntries)
          ..where((t) => t.isFavorite.equals(true))
          ..where((t) => t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
    return q.map((rows) => rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList());
  }


  // Получить количество элементов
  Future<int> count() async {
    return (select(wardrobeEntries)..where((t) => t.isArchived.equals(false))).get().then((value) => value.length);
  }

  // Отметить как синхронизированное
  Future<void> markAsSynced(String id, String serverId) {
    return (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        serverId: Value(serverId),
        lastSyncedAt: Value(DateTime.now()),
        dirty: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Получить несинхронизированные элементы
  Future<List<domain.WardrobeEntry>> getUnsynced() async {
    final rows = await (select(wardrobeEntries)
          ..where((t) => t.dirty.equals(true) | t.lastSyncedAt.isNull()))
        .get();
    return rows.map((row) => domain.WardrobeEntry.fromDbEntity(row)).toList();
  }

  // Сбросить счетчик использования
  Future<void> resetWearCount(String id) {
    return (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        wearCount: const Value(0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Обновить дату последнего ношения
  Future<void> updateLastWorn(String id, DateTime date) {
    return (update(wardrobeEntries)..where((t) => t.id.equals(id))).write(
      WardrobeEntriesCompanion(
        lastWornAt: Value(date),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}