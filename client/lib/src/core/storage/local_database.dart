import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:drift/native.dart' as native;

part 'local_database.g.dart';

// Drift table definition for outfit recommendations
class RecommendationTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get outfitItems => text()(); // JSON string of outfit items
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
  TextColumn get externalId => text().unique()(); // UUID from server
  TextColumn get name => text()();
  TextColumn get imageUrl => text()();
  TextColumn get category => text()();
  TextColumn get season => text()();
  TextColumn get weatherCondition => text()();
  RealColumn get temperatureMin => real()();
  RealColumn get temperatureMax => real()();
  TextColumn get occasions => text()(); // JSON string of occasions
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
  int get schemaVersion => 2; // Updated to version 2

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      _logger.i('Creating database schema version $schemaVersion');
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      _logger.i('Upgrading database from version $from to $to');
      
      if (from < 2) {
        // Add new tables for version 2
        await m.createTable(wardrobeTable);
        await m.createTable(weatherDataTable);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign key constraints
      await customStatement('PRAGMA foreign_keys = ON;');
      _logger.d('Foreign key constraints enabled');

      // Set database security options
      await customStatement('PRAGMA journal_mode = WAL;');
      _logger.d('Write-Ahead Logging enabled for better concurrency');

      // Enable secure delete to zero out deleted data
      await customStatement('PRAGMA secure_delete = ON;');
      _logger.d('Secure delete enabled');
    },
  );

  /// Create a secure database connection with proper error handling
  static QueryExecutor _createConnection() {
    try {
      return LazyDatabase(() async {
        final dbFolder = await getApplicationDocumentsDirectory();

        // Validate the directory exists and is accessible
        if (!await dbFolder.exists()) {
          await dbFolder.create(recursive: true);
        }

        // Ensure proper permissions for the database directory
        await _ensureSecureDirectory(dbFolder);

        final fileName = 'outfitstyle_${_generateDbHash()}.sqlite';
        final file = File(path.join(dbFolder.path, fileName));

        // Check if file exists and validate its integrity
        if (await file.exists()) {
          await _validateDatabaseFile(file);
        }

        return native.NativeDatabase(file, logStatements: _shouldLogSql());
      });
    } catch (e) {
      Logger().e('Failed to create database connection', error: e);
      rethrow;
    }
  }

  /// Generate a unique hash for the database filename to prevent conflicts
  static String _generateDbHash() {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(salt);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8);
  }

  /// Ensure the database directory has secure permissions
  static Future<void> _ensureSecureDirectory(Directory dir) async {
    try {
      // On Android/iOS, we rely on platform security
      // But we can still verify the directory is properly isolated
      if (!dir.path.contains('documents') && !dir.path.contains('app_flutter')) {
        throw SecurityException('Database directory appears to be outside app storage');
      }

      // Verify we can write to the directory
      final testFile = File(path.join(dir.path, '.permission_test'));
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      Logger().e('Security validation failed for database directory', error: e);
      rethrow;
    }
  }

  /// Validate database file integrity
  static Future<void> _validateDatabaseFile(File file) async {
    try {
      if (await file.length() == 0) {
        Logger().w('Database file is empty, this might be intentional');
        return;
      }

      // Check if the file looks like a SQLite database
      final bytes = await file.readAsBytes();
      if (bytes.length >= 16) {
        final header = String.fromCharCodes(bytes.take(16));
        if (!header.startsWith('SQLite format 3')) {
          throw DatabaseException('File does not appear to be a valid SQLite database');
        }
      }
    } catch (e) {
      Logger().e('Database file validation failed', error: e);
      rethrow;
    }
  }

  /// Determine if SQL statements should be logged based on environment
  static bool _shouldLogSql() {
    const shouldLog = bool.fromEnvironment('LOG_SQL_QUERIES', defaultValue: false);
    return shouldLog;
  }

  /// Perform a safe database operation with error handling
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

  /// Close the database connection properly
  @override
  Future<void> close() async {
    await super.close();
  }

  /// Get database statistics for monitoring purposes
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final stats = <String, dynamic>{};

      // Get table count
      final tableCountResult = await customSelect('SELECT COUNT(*) as count FROM sqlite_master WHERE type="table"').getSingle();
      stats['table_count'] = tableCountResult.read<int>('count');

      // Get database size
      final dbFolder = await getApplicationDocumentsDirectory();
      final fileName = 'outfitstyle_${_generateDbHash()}.sqlite';
      final file = File(path.join(dbFolder.path, fileName));
      if (await file.exists()) {
        stats['size_bytes'] = await file.length();
      }

      // Get SQLite-specific stats
      final pragmaResults = await customSelect('PRAGMA compile_options;').get();
      stats['compile_options'] = pragmaResults.map((row) => row.read<String>('compile_options')).toList();

      _logger.d('Retrieved database statistics', error: stats);
      return stats;
    } catch (e) {
      _logger.e('Failed to retrieve database statistics', error: e);
      rethrow;
    }
  }
}

/// Custom exception for database-related errors
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Custom exception for security-related errors
class SecurityException implements Exception {
  final String message;

  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}