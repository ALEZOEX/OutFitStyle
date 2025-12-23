import 'dart:convert';
import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../local/dao/wardrobe_dao.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../sync/outbox_actions.dart';
import '../images/image_store.dart';

class WardrobeRepository {
  final AppDatabase db;
  final WardrobeRemoteDataSource remote;

  WardrobeRepository({
    required this.db,
    required this.remote,
  });

  WardrobeDao get _dao => db.wardrobeDao;

  Stream<List<WardrobeEntry>> watchWardrobe({bool includeArchived = false}) {
    return _dao.watchAll(includeArchived: includeArchived);
  }

  /// "Тихий" sync: подтягиваем с сервера и делаем upsert в локальную БД
  Future<void> syncFromServer() async {
    final remoteItems = await remote.fetchAll();

    final now = DateTime.now();
    final rows = remoteItems.map((wi) {
      final item = wi.item;

      return WardrobeEntriesCompanion(
        id: Value(wi.id),
        name: Value(item.name),
        category: Value(item.category),
        subcategory: Value(item.subcategory),
        style: Value(item.style),
        iconEmoji: Value(item.iconEmoji ?? '👕'),
        isFavorite: Value(wi.isFavorite),
        isArchived: Value(wi.isArchived),
        wearCount: Value(wi.wearCount),
        updatedAt: Value(now),
        dirty: const Value(false),
        lastSyncedAt: Value(now),
      );
    }).toList();

    await _dao.upsertMany(rows);
  }

  /// Оптимистичный UI: сначала пишем в БД (мгновенно), потом пушим на сервер
  Future<void> toggleFavorite(WardrobeEntry e) async {
    final newValue = !e.isFavorite;
    await _dao.setFavorite(e.id, newValue);

    try {
      await remote.setFavorite(e.id, newValue);
      await (db.update(db.wardrobeEntries)..where((t) => t.id.equals(e.id))).write(
        WardrobeEntriesCompanion(dirty: const Value(false), lastSyncedAt: Value(DateTime.now())),
      );
    } catch (err) {
      await db.syncOutboxDao.enqueue(
        type: OutboxActions.wardrobeSetFavorite,
        entityId: e.id,
        payloadJson: jsonEncode({'id': e.id, 'value': newValue}),
      );
      // НЕ rethrow: UI уже обновлён оптимистично, синк догонит
    }
  }

  Future<void> toggleArchived(WardrobeEntry e) async {
    final newValue = !e.isArchived;
    await _dao.setArchived(e.id, newValue);

    try {
      await remote.setArchived(e.id, newValue);
      await (db.update(db.wardrobeEntries)..where((t) => t.id.equals(e.id))).write(
        WardrobeEntriesCompanion(dirty: const Value(false), lastSyncedAt: Value(DateTime.now())),
      );
    } catch (err) {
      await db.syncOutboxDao.enqueue(
        type: OutboxActions.wardrobeSetArchived,
        entityId: e.id,
        payloadJson: jsonEncode({'id': e.id, 'value': newValue}),
      );
    }
  }

  Future<void> markWorn(WardrobeEntry e) async {
    await _dao.incrementWear(e.id);

    try {
      await remote.worn(e.id);
      await (db.update(db.wardrobeEntries)..where((t) => t.id.equals(e.id))).write(
        WardrobeEntriesCompanion(dirty: const Value(false), lastSyncedAt: Value(DateTime.now())),
      );
    } catch (err) {
      await db.syncOutboxDao.enqueue(
        type: OutboxActions.wardrobeWorn,
        entityId: e.id,
        payloadJson: jsonEncode({'id': e.id}),
      );
    }
  }

  Future<void> prefetchMissingImages({int limit = 30}) async {
    final missing = await _dao.findMissingLocalImages(limit: limit);

    for (final e in missing) {
      final url = e.imageUrl;
      if (url == null || url.isEmpty) continue;

      try {
        final local = await ImageStore.ensureLocalCopy(url);
        if (local != null && local.isNotEmpty) {
          await _dao.setLocalImagePath(e.id, local);
        }
      } catch (_) {
        // не падаем: это "улучшение", а не критичный функционал
      }
    }
  }
}