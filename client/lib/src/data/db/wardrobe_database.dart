import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

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
        // Миграции будут добавляться по мере необходимости
        if (from < 2) {
          // Пример миграции для версии 2
          // await m.addColumn(clothingItems, clothingItems.newColumn);
        }
      },
      beforeOpen: (OpeningDetails details) async {
        // Включение foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ==================== ClothingItems CRUD ====================

  /// Получить все элементы одежды
  Future<List<DbClothingItem>> getAllClothingItems({
    bool includeArchived = false,
  }) async {
    if (!includeArchived) {
      return (select(clothingItems)..where((tbl) => tbl.isArchived.equals(false)))
          .get();
    }
    return select(clothingItems).get();
  }

  /// Получить поток всех элементов одежды
  Stream<List<DbClothingItem>> watchAllClothingItems({
    bool includeArchived = false,
  }) {
    if (!includeArchived) {
      return (select(clothingItems)
            ..where((tbl) => tbl.isArchived.equals(false))
            ..orderBy([
              (t) => OrderingTerm.desc(t.addedDate),
            ]))
          .watch();
    }
    return (select(clothingItems)
          ..orderBy([
            (t) => OrderingTerm.desc(t.addedDate),
          ]))
        .watch();
  }

  /// Получить элемент по ID
  Future<DbClothingItem?> getClothingItemById(int id) async {
    return (select(clothingItems)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Получить элемент по externalId
  Future<DbClothingItem?> getClothingItemByExternalId(String externalId) async {
    return (select(clothingItems)..where((tbl) => tbl.externalId.equals(externalId)))
        .getSingleOrNull();
  }

  /// Получить элемент по serverId
  Future<DbClothingItem?> getClothingItemByServerId(String serverId) async {
    return (select(clothingItems)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  /// Вставить элемент
  Future<int> insertClothingItem(ClothingItemsCompanion item) async {
    return into(clothingItems).insert(item);
  }

  /// Обновить элемент
  Future<void> updateClothingItem(DbClothingItem item) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(item.id)))
        .write(item);
  }

  /// Обновить элемент по ID
  Future<void> updateClothingItemById(
    int id,
    ClothingItemsCompanion item,
  ) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(id)))
        .write(item);
  }

  /// Удалить элемент
  Future<bool> deleteClothingItem(int id) async {
    return (await (delete(clothingItems)..where((tbl) => tbl.id.equals(id))).go()) > 0;
  }

  /// Получить несинхронизированные элементы
  Future<List<DbClothingItem>> getUnsyncedClothingItems() async {
    return (select(clothingItems)..where((tbl) => tbl.dirty.equals(true))).get();
  }

  /// Отметить элемент как синхронизированный
  Future<void> markClothingItemAsSynced(int id, String serverId) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(id))).write(
      ClothingItemsCompanion(
        serverId: Value(serverId),
        dirty: const Value(false),
        lastSyncedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Пометить элемент как изменённый (dirty)
  Future<void> markClothingItemAsDirty(int id) async {
    await (update(clothingItems)..where((tbl) => tbl.id.equals(id))).write(
      ClothingItemsCompanion(
        dirty: const Value(true),
      ),
    );
  }

  /// Получить избранные элементы
  Future<List<DbClothingItem>> getFavoriteClothingItems() async {
    return (select(clothingItems)..where((tbl) => tbl.isFavorite.equals(true))).get();
  }

  /// Получить элементы по категории
  Future<List<DbClothingItem>> getClothingItemsByCategory(String category) async {
    return (select(clothingItems)..where((tbl) => tbl.category.equals(category)))
        .get();
  }

  // ==================== Outfits CRUD ====================

  /// Получить все образы
  Future<List<DbOutfit>> getAllOutfits() async {
    return select(outfits).get();
  }

  /// Получить поток всех образов
  Stream<List<DbOutfit>> watchAllOutfits() {
    return (select(outfits)
          ..orderBy([
            (t) => OrderingTerm.desc(t.addedDate),
          ]))
        .watch();
  }

  /// Получить образ по ID
  Future<DbOutfit?> getOutfitById(int id) async {
    return (select(outfits)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  /// Получить образ по externalId
  Future<DbOutfit?> getOutfitByExternalId(String externalId) async {
    return (select(outfits)..where((tbl) => tbl.externalId.equals(externalId)))
        .getSingleOrNull();
  }

  /// Получить образ по serverId
  Future<DbOutfit?> getOutfitByServerId(String serverId) async {
    return (select(outfits)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  /// Вставить образ
  Future<int> insertOutfit(OutfitsCompanion outfit) async {
    return into(outfits).insert(outfit);
  }

  /// Обновить образ
  Future<void> updateOutfit(DbOutfit outfit) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(outfit.id))).write(outfit);
  }

  /// Обновить образ по ID
  Future<void> updateOutfitById(int id, OutfitsCompanion outfit) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(id))).write(outfit);
  }

  /// Удалить образ
  Future<bool> deleteOutfit(int id) async {
    return (await (delete(outfits)..where((tbl) => tbl.id.equals(id))).go()) > 0;
  }

  /// Получить несинхронизированные образы
  Future<List<DbOutfit>> getUnsyncedOutfits() async {
    return (select(outfits)..where((tbl) => tbl.dirty.equals(true))).get();
  }

  /// Отметить образ как синхронизированный
  Future<void> markOutfitAsSynced(int id, String serverId) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(id))).write(
      OutfitsCompanion(
        serverId: Value(serverId),
        dirty: const Value(false),
        lastSyncedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Пометить образ как изменённый (dirty)
  Future<void> markOutfitAsDirty(int id) async {
    await (update(outfits)..where((tbl) => tbl.id.equals(id))).write(
      OutfitsCompanion(
        dirty: const Value(true),
      ),
    );
  }

  /// Получить избранные образы
  Future<List<DbOutfit>> getFavoriteOutfits() async {
    return (select(outfits)..where((tbl) => tbl.isFavorite.equals(true))).get();
  }

  // ==================== OutfitItems CRUD ====================

  /// Получить все элементы образа
  Future<List<DbOutfitItem>> getOutfitItemsByOutfitId(int outfitId) async {
    return (select(outfitItems)
          ..where((tbl) => tbl.outfitId.equals(outfitId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }

  /// Получить поток элементов образа
  Stream<List<DbOutfitItem>> watchOutfitItemsByOutfitId(int outfitId) {
    return (select(outfitItems)
          ..where((tbl) => tbl.outfitId.equals(outfitId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .watch();
  }

  /// Получить элемент связи по ID
  Future<DbOutfitItem?> getOutfitItemById(int id) async {
    return (select(outfitItems)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Вставить элемент связи
  Future<int> insertOutfitItem(OutfitItemsCompanion item) async {
    return into(outfitItems).insert(item);
  }

  /// Вставить несколько элементов связи
  Future<void> insertOutfitItems(List<OutfitItemsCompanion> items) async {
    await batch((batch) {
      for (final item in items) {
        batch.insert(outfitItems, item);
      }
    });
  }

  /// Обновить элемент связи
  Future<void> updateOutfitItem(DbOutfitItem item) async {
    await (update(outfitItems)..where((tbl) => tbl.id.equals(item.id)))
        .write(item);
  }

  /// Удалить элемент связи
  Future<bool> deleteOutfitItem(int id) async {
    return (await (delete(outfitItems)..where((tbl) => tbl.id.equals(id))).go()) > 0;
  }

  /// Удалить все элементы связи для образа
  Future<void> deleteOutfitItemsByOutfitId(int outfitId) async {
    await (delete(outfitItems)..where((tbl) => tbl.outfitId.equals(outfitId))).go();
  }

  /// Получить образы для элемента одежды
  Future<List<DbOutfitItem>> getOutfitItemsByClothingItemId(int clothingItemId) async {
    return (select(outfitItems)..where((tbl) => tbl.clothingItemId.equals(clothingItemId)))
        .get();
  }

  // ==================== Batch Operations ====================

  /// Выполнить пакетную операцию
  Future<void> batchOperation(Future<void> Function(Batch batch) action) async {
    await batch(action);
  }

  // ==================== Utility Methods ====================

  /// Очистить базу данных (для тестов)
  Future<void> clearAllData() async {
    await batch((batch) {
      batch.deleteAll(outfitItems);
      batch.deleteAll(outfits);
      batch.deleteAll(clothingItems);
    });
  }

  /// Закрыть соединение с БД
  @override
  Future<void> close() async {
    await super.close();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wardrobe.sqlite'));

    if (Platform.isAndroid || Platform.isIOS) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
