import 'dart:async';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

// Conditional import for connection creation
import 'local_database_io.dart' if (dart.library.html) 'local_database_web.dart';

part 'local_database.g.dart';

// Drift table definition for outfit recommendations
class RecommendationTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get outfitItems => text()();
  RealColumn get temperature => real()();
  TextColumn get weatherCondition => text()();
  TextColumn get occasion => text()();
  IntColumn get timestamp => integer()();
  RealColumn get confidenceScore => real()();
  TextColumn get feedback => text().nullable()();
  IntColumn get rating => integer().nullable()();
}

// Drift table definition for wardrobe items
class WardrobeTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().unique()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  TextColumn get category => text()();
  TextColumn get season => text()();
  TextColumn get weatherCondition => text()();
  RealColumn get temperatureMin => real()();
  RealColumn get temperatureMax => real()();
  TextColumn get occasions => text()();
  IntColumn get addedAt => integer()();
  BoolColumn get isActive => boolean()();
  BoolColumn get isFavorite => boolean()();
  BoolColumn get isArchived => boolean()();
  IntColumn get wearCount => integer()();
  IntColumn get lastWornAt => integer().nullable()();
  BoolColumn get isSynced => boolean()();
  IntColumn get updatedAt => integer()();
}

// Drift table definition for weather data
class WeatherDataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get locationName => text()();
  RealColumn get temperature => real()();
  RealColumn get feelsLike => real()();
  RealColumn get tempMin => real()();
  RealColumn get tempMax => real()();
  IntColumn get pressure => integer()();
  IntColumn get humidity => integer()();
  RealColumn get dewPoint => real()();
  RealColumn get uvi => real()();
  IntColumn get clouds => integer()();
  IntColumn get visibility => integer()();
  RealColumn get windSpeed => real()();
  IntColumn get windDeg => integer()();
  RealColumn get windGust => real().nullable()();
  TextColumn get weatherMain => text()();
  TextColumn get weatherDescription => text()();
  TextColumn get weatherIcon => text()();
  IntColumn get timestamp => integer()();
  IntColumn get timezone => integer()();
  TextColumn get country => text()();
  IntColumn get sunrise => integer()();
  IntColumn get sunset => integer()();
  BoolColumn get isCurrent => boolean()();
}

@DriftDatabase(tables: [RecommendationTable, WardrobeTable, WeatherDataTable])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase({Logger? logger})
    : _logger = logger ?? Logger(),
      super(_createConnection());

  final Logger _logger;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      _logger.i('Creating database schema version $schemaVersion');
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      _logger.i('Upgrading database from version $from to $to');
      if (from < 2) {
        await m.createTable(wardrobeTable);
        await m.createTable(weatherDataTable);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA secure_delete = ON;');
    },
  );

  Future<T> safeTransaction<T>(Future<T> Function() transaction) async {
    try {
      final result = await transaction();
      _logger.d('Successfully executed database transaction');
      return result;
    } catch (e) {
      _logger.e('Database transaction failed', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final stats = <String, dynamic>{};
      final tableCountResult = await customSelect(
        'SELECT COUNT(*) as count FROM sqlite_master WHERE type="table"',
      ).getSingle();
      stats['table_count'] = tableCountResult.read<int>('count');
      return stats;
    } catch (e) {
      _logger.e('Failed to retrieve database statistics', error: e);
      rethrow;
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => 'DatabaseException: $message';
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}

QueryExecutor _createConnection() => createConnectionIo();
