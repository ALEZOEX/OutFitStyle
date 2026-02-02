import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../domain/entities/recommendation_entity.dart';

part 'recommendation_dao.g.dart';

@DriftAccessor(tables: [Recommendations])
class RecommendationDao extends DatabaseAccessor<AppDatabase>
    with _$RecommendationDaoMixin {
  RecommendationDao(super.db);

  Stream<RecommendationRow?> watchLatest() {
    final q = (select(recommendations)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
    return q;
  }

  Stream<RecommendationRow?> watchLatestForDay(DateTime dayLocal) {
    final start = DateTime(dayLocal.year, dayLocal.month, dayLocal.day);
    final end = start.add(const Duration(days: 1));

    final q = (select(recommendations)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(start))
          ..where((t) => t.createdAt.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .watchSingleOrNull();
    return q;
  }

  Stream<List<RecommendationRow>> watchHistory({int limit = 50}) {
    final q = (select(recommendations)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .watch();
    return q;
  }

  Stream<RecommendationRow?> watchById(String id) {
    return (select(recommendations)..where((t) => t.id.equals(id))).watchSingleOrNull();
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
}