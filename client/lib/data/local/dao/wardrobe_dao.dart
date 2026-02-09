import 'package:drift/drift.dart';
import '../app_database.dart';

part 'wardrobe_dao.g.dart';

@DriftAccessor(tables: [WardrobeItems])
class WardrobeDao extends DatabaseAccessor<AppDatabase>
    with _$WardrobeDaoMixin {
  WardrobeDao(super.db);

  Stream<List<WardrobeItem>> watchAll() {
    return select(wardrobeItems).watch();
  }

  Stream<WardrobeItem?> watchById(String id) {
    return (select(wardrobeItems)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<WardrobeItem?> getById(String id) async {
    return await (select(wardrobeItems)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertOne(WardrobeItemsCompanion companion) {
    return into(wardrobeItems).insertOnConflictUpdate(companion);
  }

  Future<void> upsertMany(List<WardrobeItemsCompanion> companions) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(wardrobeItems, companions);
    });
  }

  Future<void> setFavorite(String id, bool value) {
    return (update(wardrobeItems)..where((t) => t.id.equals(id))).write(
      WardrobeItemsCompanion(
        isFavorite: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setAvailable(String id, bool value) {
    return (update(wardrobeItems)..where((t) => t.id.equals(id))).write(
      WardrobeItemsCompanion(
        isAvailable: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementWearCount(String id) {
    return customUpdate(
      'UPDATE wardrobe_items SET wear_count = wear_count + 1, last_worn_date = ? WHERE id = ?',
      variables: [
        Variable.withDateTime(DateTime.now()),
        Variable.withString(id),
      ],
    );
  }

  Future<void> insertOne(WardrobeItemsCompanion companion) {
    return into(wardrobeItems).insert(companion);
  }

  Future<void> updateOne(WardrobeItemsCompanion companion) {
    // Для обновления нужен ID
    if (companion.id.present) {
      return (update(wardrobeItems)
            ..where((t) => t.id.equals(companion.id.value)))
          .write(companion);
    }
    throw Exception('ID must be present for update operation');
  }

  Future<void> deleteById(String id) {
    return (delete(wardrobeItems)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<WardrobeItem>> watchByCategory(String category) {
    return (select(wardrobeItems)
          ..where((t) => t.category.equals(category)))
        .watch();
  }

  // Получить все элементы (однократно)
  Future<List<WardrobeItem>> getAll() async {
    return await select(wardrobeItems).get();
  }

  // Получить элементы по категориям
  Future<List<WardrobeItem>> getByCategories(
      List<String> categories) async {
    return await (select(wardrobeItems)
          ..where((t) => t.category.isIn(categories))
          ..where((t) => t.isAvailable.equals(true)))
        .get();
  }

  // Получить элементы по сезону
  Stream<List<WardrobeItem>> watchBySeason(String season) {
    return (select(wardrobeItems)
          ..where((t) => t.season.equals(season))
          ..where((t) => t.isAvailable.equals(true)))
        .watch();
  }

  // Получить элементы по температуре
  Future<List<WardrobeItem>> getByTemperature(double temperature) async {
    return await (select(wardrobeItems)
          ..where((t) => t.temperatureRange.isNotNull())
          ..where((t) => t.isAvailable.equals(true)))
        .get()
        .then((items) => items.where((item) {
          final tempRange = item.temperatureRange.cast<double>();
          if (tempRange.length >= 2) {
            return temperature >= tempRange[0] && temperature <= tempRange[1];
          }
          return false;
        }).toList());
  }

  // Получить избранные элементы
  Stream<List<WardrobeItem>> watchFavorites() {
    return (select(wardrobeItems)
          ..where((t) => t.isFavorite.equals(true))
          ..where((t) => t.isAvailable.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.addedDate)]))
        .watch();
  }

  // Получить количество элементов
  Future<int> count() async {
    return await (select(wardrobeItems)..where((t) => t.isAvailable.equals(true)))
        .get()
        .then((value) => value.length);
  }

  // Сбросить счетчик использования
  Future<void> resetWearCount(String id) {
    return (update(wardrobeItems)..where((t) => t.id.equals(id))).write(
      WardrobeItemsCompanion(
        wearCount: const Value(0),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Обновить дату последнего ношения
  Future<void> updateLastWorn(String id, DateTime date) {
    return (update(wardrobeItems)..where((t) => t.id.equals(id))).write(
      WardrobeItemsCompanion(
        lastWornDate: Value(date),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
