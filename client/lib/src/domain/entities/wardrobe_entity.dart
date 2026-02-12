import 'package:drift/drift.dart';

// Таблица для элементов гардероба в базе данных
class WardrobeEntries extends Table {
  @override
  Set<Column> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get clothingItemId => text()();
  TextColumn get customName => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text()(); // JSON string of tags
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  TextColumn get purchaseCurrency => text().nullable()();
  IntColumn get wearCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastWornAt => dateTime().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get condition => text().withDefault(const Constant('good'))();

  // Weather properties
  BoolColumn get rainOk => boolean().withDefault(const Constant(false))();
  BoolColumn get snowOk => boolean().withDefault(const Constant(false))();
  BoolColumn get windOk => boolean().withDefault(const Constant(false))();
  IntColumn get minTemp => integer().nullable()();
  IntColumn get maxTemp => integer().nullable()();
  IntColumn get warmthLevel => integer().nullable()();

  // Item properties (copied from clothing catalog but customizable)
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get subcategory => text()();
  TextColumn get style => text()();
  TextColumn get iconEmoji => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get blurHash => text().nullable()();
  TextColumn get usage => text().nullable()();
  TextColumn get materials => text().nullable()();
  TextColumn get season => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get fit => text().nullable()();
  TextColumn get pattern => text().nullable()();
  TextColumn get localImagePath => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
}
