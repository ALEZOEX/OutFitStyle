import 'dart:async';
import 'dart:io';
import 'dart:convert' show utf8;
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:drift/native.dart' as native;

/// Исключение для ошибок безопасности
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}

/// Исключение для ошибок БД
class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
  @override
  String toString() => 'DatabaseException: $message';
}

/// Создает соединение с БД для IO платформ (Android, iOS, Desktop)
QueryExecutor createConnectionIo() {
  try {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();

      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }

      await _ensureSecureDirectory(dbFolder);

      final fileName = 'outfitstyle_${_generateDbHash()}.sqlite';
      final file = File(path.join(dbFolder.path, fileName));

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

/// Generate a unique hash for the database filename
String _generateDbHash() {
  final salt = DateTime.now().millisecondsSinceEpoch.toString();
  final bytes = utf8.encode(salt);
  final digest = sha256.convert(bytes);
  return digest.toString().substring(0, 8);
}

/// Ensure the database directory has secure permissions
Future<void> _ensureSecureDirectory(Directory dir) async {
  try {
    if (!dir.path.contains('documents') && !dir.path.contains('app_flutter')) {
      throw SecurityException('Database directory appears to be outside app storage');
    }
    final testFile = File(path.join(dir.path, '.permission_test'));
    await testFile.writeAsString('test');
    await testFile.delete();
  } catch (e) {
    Logger().e('Security validation failed for database directory', error: e);
    rethrow;
  }
}

/// Validate database file integrity
Future<void> _validateDatabaseFile(File file) async {
  try {
    if (await file.length() == 0) {
      Logger().w('Database file is empty');
      return;
    }
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

/// Determine if SQL statements should be logged
bool _shouldLogSql() {
  const shouldLog = bool.fromEnvironment('LOG_SQL_QUERIES', defaultValue: false);
  return shouldLog;
}
