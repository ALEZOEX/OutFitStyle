import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/recommendation_models.dart';
import '../local/app_database.dart';
import '../remote/recommendation_remote_ds.dart';
import '../sync/outbox_actions.dart';

class RecommendationRepository {
  final AppDatabase db;
  final RecommendationRemoteDataSource remote;

  RecommendationRepository({required this.db, required this.remote});

  Stream<RecommendationRow?> watchTodayLatest() {
    return db.recommendationDao.watchLatestForDay(DateTime.now());
  }

  Stream<RecommendationRow?> watchLatest() => db.recommendationDao.watchLatest();
  Stream<List<RecommendationRow>> watchHistory({int limit = 50}) =>
      db.recommendationDao.watchHistory(limit: limit);

  Future<void> ensureToday({String occasion = 'daily'}) async {
    // Если в БД уже есть "сегодняшний" — ничего не делаем.
    final start = DateTime.now();
    final sub = db.recommendationDao.watchLatestForDay(start);
    final current = await sub.first;
    if (current != null) return;

    // Иначе создаём и сохраняем локально.
    final rec = await remote.createUsingProfile(occasion: occasion);
    await _saveRecord(rec);
  }

  Future<void> createNew({required String occasion}) async {
    final rec = await remote.createUsingProfile(occasion: occasion);
    await _saveRecord(rec);
  }

  Future<void> syncHistory({int pages = 2, int limit = 20}) async {
    final now = DateTime.now();
    final rows = <RecommendationsCompanion>[];

    for (var page = 1; page <= pages; page++) {
      final (list, _) = await remote.list(page: page, limit: limit);
      for (final r in list) {
        rows.add(
          RecommendationsCompanion(
            id: Value(r.id),
            createdAt: Value(r.createdAt),
            isFavorite: Value(r.isFavorite),
            outfitDataJson: Value(jsonEncode(r.outfitData)),
            weatherDataJson: Value(jsonEncode(r.weatherData)),
            updatedAt: Value(now),
            dirty: const Value(false),
            lastSyncedAt: Value(now),
          ),
        );
      }
    }

    await db.recommendationDao.upsertMany(rows);
  }

  Future<void> toggleFavorite(RecommendationRow row) async {
    final newValue = !row.isFavorite;
    await db.recommendationDao.setFavorite(row.id, newValue);

    try {
      await remote.setFavorite(id: row.id, isFavorite: newValue);
      await (db.update(db.recommendations)..where((t) => t.id.equals(row.id))).write(
        RecommendationsCompanion(
          dirty: const Value(false),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    } catch (err) {
      await db.syncOutboxDao.enqueue(
        type: OutboxActions.recSetFavorite,
        entityId: row.id,
        payloadJson: jsonEncode({'id': row.id, 'value': newValue}),
      );
    }
  }

  Future<void> _saveRecord(RecommendationRecord r) async {
    final now = DateTime.now();
    await db.recommendationDao.upsertOne(
      RecommendationsCompanion(
        id: Value(r.id),
        createdAt: Value(r.createdAt),
        isFavorite: Value(r.isFavorite),
        outfitDataJson: Value(jsonEncode(r.outfitData)),
        weatherDataJson: Value(jsonEncode(r.weatherData)),
        updatedAt: Value(now),
        dirty: const Value(false),
        lastSyncedAt: Value(now),
      ),
    );
  }

  Stream<RecommendationRow?> watchById(String id) => db.recommendationDao.watchById(id);

  Future<String> saveLocalOutfit({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
    bool favorite = true,
  }) async {
    final id = 'local_${const Uuid().v4()}';
    final now = DateTime.now();

    await db.recommendationDao.insertLocal(
      id: id,
      createdAt: now,
      isFavorite: favorite,
      outfitDataJson: jsonEncode(outfitData),
      weatherDataJson: jsonEncode(weatherData),
    );

    // Автопубликация через outbox (невидимо для пользователя)
    await enqueuePublishLocalOutfit(id);

    return id;
  }

  Future<void> enqueuePublishLocalOutfit(String localId) async {
    final row = await (db.select(db.recommendations)
          ..where((t) => t.id.equals(localId))
          ..limit(1))
        .getSingleOrNull();

    if (row == null) return;
    if (!row.id.startsWith('local_')) return;
    if (row.serverId != null) return; // уже опубликовано

    await db.syncOutboxDao.enqueue(
      type: OutboxActions.outfitPublishLocal,
      entityId: localId,
      payloadJson: jsonEncode({
        'local_id': localId,
        'outfit_data_json': row.outfitDataJson,
        'weather_data_json': row.weatherDataJson,
      }),
    );
  }
}