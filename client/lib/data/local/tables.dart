import 'package:drift/drift.dart';

// Таблица для рекомендаций
class Recommendations extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get origin => text()();
  TextColumn get outfitDataJson => text()();
  TextColumn get weatherDataJson => text()();
  BoolColumn get isFavorite => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
}

// Таблица для элементов гардероба
class WardrobeEntries extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get subcategory => text()();
  TextColumn get style => text()();
  TextColumn get iconEmoji => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get blurHash => text().nullable()();
  IntColumn get minTemp => integer().nullable()();
  IntColumn get maxTemp => integer().nullable()();
  IntColumn get warmthLevel => integer().nullable()();
  BoolColumn get rainOk => boolean()();
  BoolColumn get snowOk => boolean()();
  BoolColumn get windOk => boolean()();
  TextColumn get usage => text().nullable()();
  TextColumn get materials => text().nullable()();
  IntColumn get wearCount => integer()();
  DateTimeColumn get lastWornAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isArchived => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean()();
  TextColumn get season => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get fit => text().nullable()();
  TextColumn get pattern => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
}

// Таблица для отложенной синхронизации (outbox pattern)
class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean()();
}

// Таблица для хранения настроек
class Settings extends Table {
  TextColumn get key => text().withLength(min: 1, max: 50)();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
