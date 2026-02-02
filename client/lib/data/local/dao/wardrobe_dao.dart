import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';
import '../../domain/entities/wardrobe_entity.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [WardrobeEntries])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  Stream<List<WardrobeEntry>> watchAll() {
    final q = select(wardrobeEntries).watch();
    return q.map((rows) => rows.map((row) => WardrobeEntry(
      id: row.id,
      serverId: row.serverId,
      name: row.name,
      category: row.category,
      subcategory: row.subcategory,
      style: row.style,
      iconEmoji: row.iconEmoji,
      imageUrl: row.imageUrl,
      blurHash: row.blurHash,
      minTemp: row.minTemp,
      maxTemp: row.maxTemp,
      warmthLevel: row.warmthLevel,
      rainOk: row.rainOk,
      snowOk: row.snowOk,
      windOk: row.windOk,
      usage: row.usage,
      materials: row.materials,
      wearCount: row.wearCount,
      lastWornAt: row.lastWornAt,
      isFavorite: row.isFavorite,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastSyncedAt: row.lastSyncedAt,
      dirty: row.dirty,
      season: row.season,
      gender: row.gender,
      fit: row.fit,
      pattern: row.pattern,
      localImagePath: row.localImagePath,
    )).toList());
  }

  Stream<WardrobeEntry?> watchById(String id) {
    final q = (select(wardrobeEntries)..where((t) => t.id.equals(id))).watchSingleOrNull();
    return q.map((row) => row != null ? WardrobeEntry(
      id: row.id,
      serverId: row.serverId,
      name: row.name,
      category: row.category,
      subcategory: row.subcategory,
      style: row.style,
      iconEmoji: row.iconEmoji,
      imageUrl: row.imageUrl,
      blurHash: row.blurHash,
      minTemp: row.minTemp,
      maxTemp: row.maxTemp,
      warmthLevel: row.warmthLevel,
      rainOk: row.rainOk,
      snowOk: row.snowOk,
      windOk: row.windOk,
      usage: row.usage,
      materials: row.materials,
      wearCount: row.wearCount,
      lastWornAt: row.lastWornAt,
      isFavorite: row.isFavorite,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastSyncedAt: row.lastSyncedAt,
      dirty: row.dirty,
      season: row.season,
      gender: row.gender,
      fit: row.fit,
      pattern: row.pattern,
      localImagePath: row.localImagePath,
    ) : null);
  }

  Future<WardrobeEntry?> getById(String id) async {
    final row = await (select(wardrobeEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      return WardrobeEntry(
        id: row.id,
        serverId: row.serverId,
        name: row.name,
        category: row.category,
        subcategory: row.subcategory,
        style: row.style,
        iconEmoji: row.iconEmoji,
        imageUrl: row.imageUrl,
        blurHash: row.blurHash,
        minTemp: row.minTemp,
        maxTemp: row.maxTemp,
        warmthLevel: row.warmthLevel,
        rainOk: row.rainOk,
        snowOk: row.snowOk,
        windOk: row.windOk,
        usage: row.usage,
        materials: row.materials,
        wearCount: row.wearCount,
        lastWornAt: row.lastWornAt,
        isFavorite: row.isFavorite,
        isArchived: row.isArchived,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        lastSyncedAt: row.lastSyncedAt,
        dirty: row.dirty,
        season: row.season,
        gender: row.gender,
        fit: row.fit,
        pattern: row.pattern,
        localImagePath: row.localImagePath,
      );
    }
    return null;
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
        DateTimeType().mapToSqlVariable(DateTime.now()),
        StringType().mapToSqlVariable(id),
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

  Stream<List<WardrobeEntry>> watchByCategory(String category) {
    final q = (select(wardrobeEntries)
          ..where((t) => t.category.equals(category)))
        .watch();
    return q.map((rows) => rows.map((row) => WardrobeEntry(
      id: row.id,
      serverId: row.serverId,
      name: row.name,
      category: row.category,
      subcategory: row.subcategory,
      style: row.style,
      iconEmoji: row.iconEmoji,
      imageUrl: row.imageUrl,
      blurHash: row.blurHash,
      minTemp: row.minTemp,
      maxTemp: row.maxTemp,
      warmthLevel: row.warmthLevel,
      rainOk: row.rainOk,
      snowOk: row.snowOk,
      windOk: row.windOk,
      usage: row.usage,
      materials: row.materials,
      wearCount: row.wearCount,
      lastWornAt: row.lastWornAt,
      isFavorite: row.isFavorite,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      lastSyncedAt: row.lastSyncedAt,
      dirty: row.dirty,
      season: row.season,
      gender: row.gender,
      fit: row.fit,
      pattern: row.pattern,
      localImagePath: row.localImagePath,
    )).toList());
  }
}