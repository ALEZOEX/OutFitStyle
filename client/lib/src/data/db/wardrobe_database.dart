import 'package:drift/drift.dart';
import 'package:drift/drift.dart' as drift;

// Conditional import for connection creation
import 'wardrobe_database_io.dart' if (dart.library.html) 'wardrobe_database_web.dart';

part 'wardrobe_database.g.dart';

/// Таблица элементов одежды
@DataClassName('DbClothingItem')
class ClothingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get category => text()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get color => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get material => text().nullable()();
  TextColumn get seasons => text().withDefault(const Constant('[]'))();
  TextColumn get weatherConditions => text().withDefault(const Constant('[]'))();
  TextColumn get occasions => text().withDefault(const Constant('[]'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get timesWorn => integer().withDefault(const Constant(0))();
  RealColumn get comfortRating => real().withDefault(const Constant(0.0))();
  IntColumn get addedDate => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get lastWornDate => integer().nullable()();
  RealColumn get price => real().nullable()();
  TextColumn get size => text().nullable()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  // Sync fields
  TextColumn get serverId => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  IntColumn get lastSyncedAt => integer().nullable()();
}

/// Таблица образов (outfits)
@DataClassName('DbOutfit')
class Outfits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get clothingItemIds => text().withDefault(const Constant('[]'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get timesWorn => integer().withDefault(const Constant(0))();
  RealColumn get comfortRating => real().withDefault(const Constant(0.0))();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get occasions => text().withDefault(const Constant('[]'))();
  TextColumn get weatherConditions => text().withDefault(const Constant('[]'))();
  TextColumn get seasons => text().withDefault(const Constant('[]'))();
  IntColumn get addedDate => integer()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  // Sync fields
  TextColumn get serverId => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  IntColumn get lastSyncedAt => integer().nullable()();
}

/// Таблица связи образов и одежды (многие-ко-многим)
@DataClassName('DbOutfitItem')
class OutfitItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get outfitId => integer()();
  IntColumn get clothingItemId => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
}

/// Основная база данных для гардероба
@DriftDatabase(tables: [ClothingItems, Outfits, OutfitItems])
class WardrobeDatabase extends _$WardrobeDatabase {
  WardrobeDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Миграции будут добавляться по мере необходимости
        }
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ==================== ClothingItems CRUD ====================

  Future<List<DbClothingItem>> getAllClothingItems({bool includeArchived = false}) async {
    if (!includeArchived) {
      return (select(clothingItems)..where((tbl) => tbl.isArchived.equals(false))).get();
    }
    return select(clothingItems).get();
  }

  Stream<List<DbClothingItem>> watchAllClothingItems({bool includeArchived = false}) {
    if (!includeArchived) {
      return (select(clothingItems)
            ..where((tbl) => tbl.isArchived.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.addedDate)]))
          .watch();
    }
    return (select(clothingItems)..orderBy([(t) => OrderingTerm.desc(t.addedDate)])).watch();
  }

  Future<DbClothingItem?> getClothingItemById(int id) async {
    return (select(clothingItems)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<DbClothingItem?> getClothingItemByExternalId(String externalId) async {
    return (select(clothingItems)..where((tbl) => tbl.externalId.equals(externalId))).getSingleOrNull();
  }

  Future<DbClothingItem?> getClothingItemByServerId(String serverId) async {
    return (select(clothingItems)..where((tbl) => tbl.serverId.equals(serverId))).getSingleOrNull();
  }

  Future<int> insertClothingItem(ClothingItemsCompanion item) async {
    return into(clothingItems).insert(item);
  }

  Future<void> updateClothingItem(DbClothingItem item) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(item.id))).write(item);
  }

  Future<void> updateClothingItemById(int id, ClothingItemsCompanion item) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(id))).write(item);
  }

  Future<bool> deleteClothingItem(int id) async {
    return (await (delete(clothingItems)..where((tbl) => tbl.id.equals(id))).go()) > 0;
  }

  Future<List<DbClothingItem>> getUnsyncedClothingItems() async {
    return (select(clothingItems)..where((tbl) => tbl.dirty.equals(true))).get();
  }

  Future<void> markClothingItemAsSynced(int id, String serverId) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(id))).write(
      ClothingItemsCompanion(
        serverId: Value(serverId),
        dirty: const Value(false),
        lastSyncedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> markClothingItemAsDirty(int id) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(id))).write(
      ClothingItemsCompanion(dirty: const Value(true)),
    );
  }

  Future<List<DbClothingItem>> getFavoriteClothingItems() async {
    return (select(clothingItems)..where((tbl) => tbl.isFavorite.equals(true))).get();
  }

  Future<List<DbClothingItem>> getClothingItemsByCategory(String category) async {
    return (select(clothingItems)..where((tbl) => tbl.category.equals(category))).get();
  }

  // ==================== Outfits CRUD ====================

  Future<List<DbOutfit>> getAllOutfits() async => select(outfits).get();

  Stream<List<DbOutfit>> watchAllOutfits() {
    return (select(outfits)..orderBy([(t) => OrderingTerm.desc(t.addedDate)])).watch();
  }

  Future<DbOutfit?> getOutfitById(int id) async {
    return (select(outfits)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<DbOutfit?> getOutfitByExternalId(String externalId) async {
    return (select(outfits)..where((tbl) => tbl.externalId.equals(externalId))).getSingleOrNull();
  }

  Future<DbOutfit?> getOutfitByServerId(String serverId) async {
    return (select(outfits)..where((tbl) => tbl.serverId.equals(serverId))).getSingleOrNull();
  }

  Future<int> insertOutfit(OutfitsCompanion outfit) async => into(outfits).insert(outfit);

  Future<void> updateOutfit(DbOutfit outfit) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(outfit.id))).write(outfit);
  }

  Future<void> updateOutfitById(int id, OutfitsCompanion outfit) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(id))).write(outfit);
  }

  Future<bool> deleteOutfit(int id) async {
    return (await (delete(outfits)..where((tbl) => tbl.id.equals(id))).go()) > 0;
  }

  Future<List<DbOutfit>> getUnsyncedOutfits() async {
    return (select(outfits)..where((tbl) => tbl.dirty.equals(true))).get();
  }

  Future<void> markOutfitAsSynced(int id, String serverId) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(id))).write(
      OutfitsCompanion(
        serverId: Value(serverId),
        dirty: const Value(false),
        lastSyncedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> markOutfitAsDirty(int id) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(id))).write(
      OutfitsCompanion(dirty: const Value(true)),
    );
  }

  Future<List<DbOutfit>> getFavoriteOutfits() async {
    return (select(outfits)..where((tbl) => tbl.isFavorite.equals(true))).get();
  }

  // ==================== OutfitItems CRUD ====================

  Future<List<DbOutfitItem>> getOutfitItemsByOutfitId(int outfitId) async {
    return (select(outfitItems)
          ..where((tbl) => tbl.outfitId.equals(outfitId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Stream<List<DbOutfitItem>> watchOutfitItemsByOutfitId(int outfitId) {
    return (select(outfitItems)
          ..where((tbl) => tbl.outfitId.equals(outfitId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<DbOutfitItem?> getOutfitItemById(int id) async {
    return (select(outfitItems)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertOutfitItem(OutfitItemsCompanion item) async {
    return into(outfitItems).insert(item);
  }

  Future<void> insertOutfitItems(List<OutfitItemsCompanion> items) async {
    await batch((batch) {
      for (final item in items) {
        batch.insert(outfitItems, item);
      }
    });
  }

  Future<void> updateOutfitItem(DbOutfitItem item) async {
    await (update(outfitItems)..where((tbl) => tbl.id.equals(item.id))).write(item);
  }

  Future<bool> deleteOutfitItem(int id) async {
    return (await (delete(outfitItems)..where((tbl) => tbl.id.equals(id))).go()) > 0;
  }

  Future<void> deleteOutfitItemsByOutfitId(int outfitId) async {
    await (delete(outfitItems)..where((tbl) => tbl.outfitId.equals(outfitId))).go();
  }

  Future<List<DbOutfitItem>> getOutfitItemsByClothingItemId(int clothingItemId) async {
    return (select(outfitItems)..where((tbl) => tbl.clothingItemId.equals(clothingItemId))).get();
  }

  // ==================== Batch Operations ====================

  Future<void> batchOperation(Future<void> Function(Batch batch) action) async {
    await batch(action);
  }

  Future<void> clearAllData() async {
    await batch((batch) {
      batch.deleteAll(outfitItems);
      batch.deleteAll(outfits);
      batch.deleteAll(clothingItems);
    });
  }
}

LazyDatabase _openConnection() => openConnectionIo();
