import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../local/app_database.dart';
import '../local/dao/sync_outbox_dao.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../remote/recommendations_remote_ds.dart';
import '../../models/wardrobe_models.dart';

class SyncWorker {
  final AppDatabase _db;
  final WardrobeRemoteDataSource _wardrobeRemote;
  final RecommendationsRemoteDataSource _recRemote;
  Timer? _periodicTimer;

  SyncWorker({
    required AppDatabase db,
    required WardrobeRemoteDataSource wardrobeRemote,
    required RecommendationsRemoteDataSource recRemote,
  })  : _db = db,
        _wardrobeRemote = wardrobeRemote,
        _recRemote = recRemote;

  Future<void> syncPendingChanges() async {
    // Получаем отложенные изменения
    final pendingChanges = await _db.syncOutboxDao.getPendingChanges();

    for (final change in pendingChanges) {
      try {
        // Выполняем синхронизацию в зависимости от типа действия
        switch (change.action) {
          case 'wardrobe_create':
            // Parse the payload to WardrobeCreateRequest
            final payload = json.decode(change.payload);
            final request = WardrobeCreateRequest(
              name: payload['name'] ?? '',
              category: payload['category'] ?? '',
              subcategory: payload['subcategory'] ?? '',
              style: payload['style'] ?? '',
              iconEmoji: payload['icon_emoji'] ?? '',
              imageUrl: payload['image_url'],
              blurHash: payload['blur_hash'],
              minTemp: payload['min_temp'],
              maxTemp: payload['max_temp'],
              warmthLevel: payload['warmth_level'],
              rainOk: payload['rain_ok'] ?? false,
              snowOk: payload['snow_ok'] ?? false,
              windOk: payload['wind_ok'] ?? false,
              usage: payload['usage'],
              materials: payload['materials'],
              isFavorite: payload['is_favorite'] ?? false,
              isArchived: payload['is_archived'] ?? false,
              season: payload['season'],
              gender: payload['gender'],
              fit: payload['fit'],
              pattern: payload['pattern'],
              localImagePath: payload['local_image_path'],
            );
            await _wardrobeRemote.create(request);
            break;
          case 'wardrobe_update':
            // Parse the payload to WardrobeUpdateRequest
            final payload = json.decode(change.payload);
            final request = WardrobeUpdateRequest(
              name: payload['name'],
              category: payload['category'],
              subcategory: payload['subcategory'],
              style: payload['style'],
              iconEmoji: payload['icon_emoji'],
              imageUrl: payload['image_url'],
              blurHash: payload['blur_hash'],
              minTemp: payload['min_temp'],
              maxTemp: payload['max_temp'],
              warmthLevel: payload['warmth_level'],
              rainOk: payload['rain_ok'],
              snowOk: payload['snow_ok'],
              windOk: payload['wind_ok'],
              usage: payload['usage'],
              materials: payload['materials'],
              isFavorite: payload['is_favorite'],
              isArchived: payload['is_archived'],
              season: payload['season'],
              gender: payload['gender'],
              fit: payload['fit'],
              pattern: payload['pattern'],
              localImagePath: payload['local_image_path'],
            );
            await _wardrobeRemote.update(change.entityId, request);
            break;
          case 'wardrobe_delete':
            await _wardrobeRemote.delete(change.entityId);
            break;
          case 'recommendation_publish':
            // For recommendations, we publish the outfit data
            final payload = json.decode(change.payload);
            await _recRemote.publishOutfit(
              outfitDataJson: payload['outfit_data'] ?? {},
              weatherDataJson: payload['weather_data'] ?? {},
            );
            break;
          case 'recommendation_favorite':
            // Toggle favorite status for recommendation
            final payload = json.decode(change.payload);
            await _recRemote.setFavorite(
              id: change.entityId,
              isFavorite: payload['is_favorite'] ?? false,
            );
            break;
          default:
            print('Unknown sync action: ${change.action}');
            continue; // Skip unknown actions
        }

        // Отмечаем, что синхронизация прошла успешно
        await _db.syncOutboxDao.markAsSynced(change.id);
      } catch (e, stackTrace) {
        // Логируем ошибку с деталями, но не прерываем синхронизацию других элементов
        print('Sync error for ${change.id} (${change.action}): $e');
        print('Stack trace: $stackTrace');

        // Optionally, we could implement retry logic or mark failed items differently
        // For now, we'll continue with other items
      }
    }
  }

  /// Метод для однократного запуска синхронизации
  Future<void> startSync() async {
    try {
      await syncPendingChanges();
    } catch (e, stackTrace) {
      // Логируем ошибку с деталями
      print('Sync error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Метод для запуска периодической синхронизации
  Future<void> startPeriodicSync() async {
    // Проверяем подключение к интернету перед синхронизацией
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      // Запускаем синхронизацию каждые 5 минут при наличии подключения
      _periodicTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
        await startSync();
      });
    }
  }

  /// Метод для остановки периодической синхронизации
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}
