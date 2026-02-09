import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ImageStore {
  static const String _tableName = 'images';
  Database? _db;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final dbPath = path.join(databasesPath, 'image_store.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        image_data BLOB NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> storeImage(String id, Uint8List imageData) async {
    await _db!.insert(
      _tableName,
      {
        'id': id,
        'image_data': imageData,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Uint8List?> getImage(String id) async {
    final result = await _db!.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first['image_data'] as Uint8List;
    }
    return null;
  }

  Future<void> deleteImage(String id) async {
    await _db!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCache() async {
    await _db!.delete(_tableName);
  }

  Future<void> close() async {
    await _db?.close();
  }
}