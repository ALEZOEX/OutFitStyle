import 'package:drift/drift.dart';

@DataClassName('WardrobeEntry')
class WardrobeEntries extends Table {
  TextColumn get id => text()(); // строка — чтобы не зависеть от формата backend
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get subcategory => text().nullable()();
  TextColumn get style => text().withDefault(const Constant(''))();
  TextColumn get iconEmoji => text().withDefault(const Constant('👕'))();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();

  TextColumn get imageUrl => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get blurHash => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// История рекомендаций/образов (offline-first)
@DataClassName('RecommendationRow')
class Recommendations extends Table {
  TextColumn get id => text()(); // local_<uuid> или server uuid

  // 'local' | 'server'
  TextColumn get origin => text().withDefault(const Constant('server'))();

  // если origin=local и опубликовано на сервер — здесь будет server uuid
  TextColumn get serverId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  TextColumn get outfitDataJson => text()();
  TextColumn get weatherDataJson => text()();

  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  DateTimeColumn get publishedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  IntColumn get localId => integer().autoIncrement()();

  /// тип операции: wardrobe_set_favorite, wardrobe_set_archived, wardrobe_worn, rec_set_favorite, ...
  TextColumn get type => text()();

  /// например id вещи/рекомендации (удобно для дедупликации и диагностики)
  TextColumn get entityId => text().nullable()();

  /// payload как JSON string (минимально необходимое)
  TextColumn get payloadJson => text()();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get nextAttemptAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get lastError => text().nullable()();
}