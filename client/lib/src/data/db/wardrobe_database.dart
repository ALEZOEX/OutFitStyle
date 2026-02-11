// Заглушка для WardrobeDatabase, чтобы избежать ошибок отсутствия зависимостей
// TODO: Реализовать полноценную базу данных позже

// Заглушка для DbClothingItem
class DbClothingItem {
  final int id;
  final String? externalId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final bool isFavorite;
  final bool isAvailable;
  final List<String> seasons;
  final List<String> weatherConditions;
  final int timesWorn;
  final int comfortRating;
  final String? brand;
  final String? color;
  final String? material;
  final DateTime addedDate;

  DbClothingItem({
    required this.id,
    this.externalId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    required this.tags,
    required this.isFavorite,
    required this.isAvailable,
    required this.seasons,
    required this.weatherConditions,
    required this.timesWorn,
    required this.comfortRating,
    this.brand,
    this.color,
    this.material,
    required this.addedDate,
  });
}

// Заглушка для DbOutfit
class DbOutfit {
  final int id;
  final String? externalId;
  final String name;
  final String? description;
  final String? imageUrl;
  final List<String> clothingItemIds;
  final bool isFavorite;
  final int timesWorn;
  final int comfortRating;
  final List<String> tags;
  final List<String> occasions;
  final List<String> weatherConditions;
  final List<String> seasons;
  final DateTime addedDate;

  DbOutfit({
    required this.id,
    this.externalId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.clothingItemIds,
    required this.isFavorite,
    required this.timesWorn,
    required this.comfortRating,
    required this.tags,
    required this.occasions,
    required this.weatherConditions,
    required this.seasons,
    required this.addedDate,
  });
}

// Заглушка для DbOutfitItem
class DbOutfitItem {
  final int id;
  final int outfitId;
  final int clothingItemId;

  DbOutfitItem({
    required this.id,
    required this.outfitId,
    required this.clothingItemId,
  });
}

// Заглушка для WardrobeDatabase
class WardrobeDatabase {
  WardrobeDatabase();

  // Заглушка для таблиц
  final ClothingItemsTableStub clothingItemsTable = ClothingItemsTableStub();
  final OutfitsTableStub outfitsTable = OutfitsTableStub();

  // Заглушка для методов Drift
  QueryExecutorStub<T> select<T>(TableStub<T> table) {
    return QueryExecutorStub<T>();
  }

  InsertableExecutorStub<T> into<T>(TableStub<T> table) {
    return InsertableExecutorStub<T>();
  }

  UpdateableExecutorStub<T> update<T>(TableStub<T> table) {
    return UpdateableExecutorStub<T>();
  }

  DeletableExecutorStub<T> delete<T>(TableStub<T> table) {
    return DeletableExecutorStub<T>();
  }
}

// Заглушка для QueryExecutor
class QueryExecutorStub<T> {
  Future<List<T>> get() async {
    return <T>[];
  }

  Future<T?> getSingleOrNull() async {
    return null;
  }

  QueryExecutorStub<T> where(dynamic condition) {
    return this;
  }
}

// Заглушка для InsertableExecutor
class InsertableExecutorStub<T> {
  Future<int> insert(dynamic item) async {
    return 0;
  }
}

// Заглушка для UpdateableExecutor
class UpdateableExecutorStub<T> {
  UpdaterStub<T> replace(T item) {
    return UpdaterStub<T>();
  }

  QueryExecutorStub<T> where(dynamic condition) {
    return QueryExecutorStub<T>();
  }
}

// Заглушка для DeletableExecutor
class DeletableExecutorStub<T> {
  Future<void> where(dynamic condition) async {}
}

// Заглушка для Updater
class UpdaterStub<T> {
  Future<void> call() async {}
}

// Заглушка для таблицы
abstract class TableStub<T> {}

// Заглушка для таблицы одежды
class ClothingItemsTableStub extends TableStub<DbClothingItem> {}

// Заглушка для таблицы образов
class OutfitsTableStub extends TableStub<DbOutfit> {}

// Заглушка для LazyDatabase
class LazyDatabase {
  LazyDatabase(Function() callback);
}

// Заглушка для ListToStringConverter
class ListToStringConverter {
  const ListToStringConverter();

  List<String> mapToDart(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',');
  }

  String mapToSql(List<String> value) {
    return value.join(',');
  }
}
