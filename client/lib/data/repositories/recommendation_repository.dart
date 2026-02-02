import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../local/app_database.dart';
import '../remote/recommendations_remote_ds.dart';
import '../../domain/entities/recommendation_entity.dart';

class RecommendationRepository {
  final AppDatabase _db;
  final RecommendationsRemoteDataSource _remote;

  RecommendationRepository(this._db, this._remote);

  // Получить историю рекомендаций
  Stream<List<RecommendationRow>> watchHistory({required int limit}) {
    return _db.recommendationDao.watchHistory(limit: limit);
  }

  // Получить рекомендацию по ID
  Stream<RecommendationRow?> watchById(String id) {
    return _db.recommendationDao.watchById(id);
  }

  // Получить сегодняшнюю последнюю рекомендацию
  Stream<RecommendationRow?> watchTodayLatest() {
    final today = DateTime.now();
    return _db.recommendationDao.watchLatestForDay(today);
  }

  // Синхронизировать с сервера
  Future<void> syncFromServer() async {
    try {
      final recommendations = await _remote.fetchHistory();
      await upsertMany(recommendations.map(RecommendationRow.fromExternal).toList());
    } catch (e) {
      // Логируем ошибку синхронизации
      // print('Recommendations sync error: $e'); // В реальном приложении используйте proper logging
      rethrow;
    }
  }

  // Вставить или обновить несколько рекомендаций
  Future<void> upsertMany(List<RecommendationRow> recommendations) async {
    await _db.transaction(() async {
      for (final rec in recommendations) {
        await _db.recommendationDao.upsertOne(RecommendationsCompanion(
          id: Value(rec.id),
          serverId: Value(rec.serverId),
          origin: Value(rec.origin),
          outfitDataJson: Value(rec.outfitDataJson),
          weatherDataJson: Value(rec.weatherDataJson),
          isFavorite: Value(rec.isFavorite),
          createdAt: Value(rec.createdAt),
          updatedAt: Value(rec.updatedAt),
          lastSyncedAt: Value(rec.lastSyncedAt),
          dirty: Value(rec.dirty),
          imageUrl: Value(rec.imageUrl),
          localImagePath: Value(rec.localImagePath),
        ));
      }
    });
  }

  // Переключить избранное
  Future<void> toggleFavorite(RecommendationRow r) async {
    await _db.recommendationDao.setFavorite(r.id, r.isFavorite);
  }

  // Предзагрузить изображения
  Future<void> prefetchMissingImages({int limit = 30}) async {
    // В реальном приложении здесь будет логика предзагрузки изображений
  }

  // Создать локальную рекомендацию
  Future<RecommendationRow> createLocal({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final recommendation = RecommendationRow(
      id: id,
      serverId: null,
      origin: 'local',
      outfitDataJson: jsonEncode(outfitData),
      weatherDataJson: jsonEncode(weatherData),
      isFavorite: false,
      createdAt: now,
      updatedAt: now,
      lastSyncedAt: null,
      dirty: true,
      imageUrl: null,
      localImagePath: null,
    );

    await _db.recommendationDao.insertLocal(
      id: recommendation.id,
      createdAt: recommendation.createdAt,
      isFavorite: recommendation.isFavorite,
      outfitDataJson: recommendation.outfitDataJson,
      weatherDataJson: recommendation.weatherDataJson,
    );

    return recommendation;
  }

  // Получить рекомендацию по ID (однократно)
  Future<RecommendationRow?> getById(String id) async {
    return await _db.recommendationDao.watchById(id).first;
  }

  // Сохранить локальный образ
  Future<RecommendationRow> saveLocalOutfit({
    required Map<String, dynamic> outfitData,
    required Map<String, dynamic> weatherData,
    required bool favorite,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    final recommendation = RecommendationRow(
      id: id,
      serverId: null,
      origin: 'local',
      outfitDataJson: jsonEncode(outfitData),
      weatherDataJson: jsonEncode(weatherData),
      isFavorite: favorite,
      createdAt: now,
      updatedAt: now,
      lastSyncedAt: null,
      dirty: true,
      imageUrl: null,
      localImagePath: null,
    );

    await _db.recommendationDao.insertLocal(
      id: recommendation.id,
      createdAt: recommendation.createdAt,
      isFavorite: recommendation.isFavorite,
      outfitDataJson: recommendation.outfitDataJson,
      weatherDataJson: recommendation.weatherDataJson,
    );

    return recommendation;
  }
}