import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Создает соединение с БД для Web платформы (IndexedDB)
QueryExecutor _createConnectionIo() {
  return LazyDatabase(() async {
    final db = await WasmDatabase.open(
      databaseName: 'outfitstyle_local_db',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );

    return db.resolvedExecutor;
  });
}
