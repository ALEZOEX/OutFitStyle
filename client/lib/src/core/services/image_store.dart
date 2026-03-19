import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ImageStore {
  static const String _tableName = 'images';
  Database? _database;

  Future<void> init() async {
    // Initialize database connection
    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'image_store.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_tableName(id TEXT PRIMARY KEY, data BLOB, created_at INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> saveImage(String id, Uint8List imageData) async {
    await _database!.insert(_tableName, {
      'id': id,
      'data': imageData,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Uint8List?> getImage(String id) async {
    final results = await _database!.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first['data'] as Uint8List;
    }
    return null;
  }

  Future<void> deleteImage(String id) async {
    await _database!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCache() async {
    await _database!.delete(_tableName);
  }
}
