import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../domain/entities/recommendation_entity.dart' as domain;

part 'recommendation_dao.g.dart';

@DriftAccessor(tables: [Recommendations])
class RecommendationDao extends DatabaseAccessor<AppDatabase>
    with _$RecommendationDaoMixin {
  RecommendationDao(super.db);

  Stream<domain.RecommendationRow?> watchLatest() {
    final q = (select(recommendations)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
    return q.map((dbRow) => dbRow != null ? domain.RecommendationRow.fromDbEntity(dbRow) : null);
  }

  Stream<domain.RecommendationRow?> watchLatestForDay(DateTime dayLocal) {
    final start = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
    final end = start.add(const Duration(days: 1));

    final q = (select(recommendations)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(start))
          ..where((t) => t.createdAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
    return q.map((dbRow) => dbRow != null ? domain.RecommendationRow.fromDbEntity(dbRow) : null);
  }

  Stream<List<domain.RecommendationRow>> watchHistory({int limit = 50}) {
    final q = (select(recommendations)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch();
    return q.map((dbRows) => dbRows.map((dbRow) => domain.RecommendationRow.fromDbEntity(dbRow)).toList());
  }

  Stream<domain.RecommendationRow?> watchById(String id) {
    return (select(recommendations)..where((t) => t.id.equals(id))).watchSingleOrNull()
        .map((dbRow) => dbRow != null ? domain.RecommendationRow.fromDbEntity(dbRow) : null);
  }

  Future<void> upsertOne(RecommendationsCompanion row) {
    return into(recommendations).insertOnConflictUpdate(row);
  }

  Future<void> upsertMany(List<RecommendationsCompanion> rows) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(recommendations, rows);
    });
  }

  Future<void> setFavorite(String id, bool value) {
    return (update(recommendations)..where((t) => t.id.equals(id))).write(
      RecommendationsCompanion(
        isFavorite: Value(value),
        dirty: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> insertLocal({
    required String id,
    required DateTime createdAt,
    required bool isFavorite,
    required String outfitDataJson,
    required String weatherDataJson,
  }) {
    return into(recommendations).insert(
      RecommendationsCompanion(
        id: Value(id),
        createdAt: Value(createdAt),
        isFavorite: Value(isFavorite),
        outfitDataJson: Value(outfitDataJson),
        weatherDataJson: Value(weatherDataJson),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(false),
        lastSyncedAt: const Value(null),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> markPublished({
    required String localId,
    required String serverId,
  }) {
    return (update(recommendations)..where((t) => t.id.equals(localId))).write(
      RecommendationsCompanion(
        origin: const Value('local'),
        serverId: Value(serverId),
        lastSyncedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Получить все рекомендации (однократно)
  Future<List<domain.RecommendationRow>> getAll() async {
    final rows = await select(recommendations).get();
    return rows.map((row) => domain.RecommendationRow.fromDbEntity(row)).toList();
  }

  // Получить рекомендацию по ID (однократно)
  Future<domain.RecommendationRow?> getById(String id) async {
    final row = await (select(recommendations)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? domain.RecommendationRow.fromDbEntity(row) : null;
  }

  // Удалить рекомендацию по ID
  Future<int> deleteById(String id) {
    return (delete(recommendations)..where((t) => t.id.equals(id))).go();
  }

  // Обновить рекомендацию
  Future<void> updateOne(RecommendationsCompanion companion) {
    if (companion.id.present) {
      return (update(recommendations)..where((t) => t.id.equals(companion.id.value))).write(companion);
    }
    throw Exception('ID must be present for update operation');
  }

  // Вставить новую рекомендацию
  Future<void> insertOne(RecommendationsCompanion companion) {
    return into(recommendations).insert(companion);
  }

  // Получить избранные рекомендации
  Stream<List<domain.RecommendationRow>> watchFavorites() {
    final q = (select(recommendations)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
    return q.map((rows) => rows.map((row) => domain.RecommendationRow.fromDbEntity(row)).toList());
  }

  // Получить рекомендации за определенный период
  Stream<List<domain.RecommendationRow>> watchByDateRange(DateTime start, DateTime end) {
    final q = (select(recommendations)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(start))
          ..where((t) => t.createdAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
    return q.map((rows) => rows.map((row) => domain.RecommendationRow.fromDbEntity(row)).toList());
  }

  // Получить количество рекомендаций
  Future<int> count() async {
    return select(recommendations).get().then((value) => value.length);
  }

  // Отметить как синхронизированное
  Future<void> markAsSynced(String id, String serverId) {
    return (update(recommendations)..where((t) => t.id.equals(id))).write(
      RecommendationsCompanion(
        serverId: Value(serverId),
        lastSyncedAt: Value(DateTime.now()),
        dirty: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Получить несинхронизированные рекомендации
  Future<List<domain.RecommendationRow>> getUnsynced() async {
    final rows = await (select(recommendations)
          ..where((t) => t.dirty.equals(true) | t.lastSyncedAt.isNull()))
        .get();
    return rows.map((row) => domain.RecommendationRow.fromDbEntity(row)).toList();
  }
}