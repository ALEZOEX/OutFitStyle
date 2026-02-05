import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../remote/recommendations_remote_ds.dart';
import '../repositories/wardrobe_repository.dart';
import '../repositories/recommendations_repository.dart';
import '../../domain/entities/wardrobe_request_entities.dart';
import 'package:drift/drift.dart';

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
            final request = WardrobeItemCreateRequest(
              name: payload['name'],
              category: payload['category'],
              subcategory: payload['subcategory'],
              style: payload['style'],
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
            // Create the wardrobe item using the repository
            await _db.wardrobeDao.insertOne(WardrobeEntriesCompanion.insert(
              id: change.entityId, // Use the entity ID from the change record
              name: request.name,
              category: request.category,
              subcategory: request.subcategory,
              style: request.style,
              iconEmoji: request.iconEmoji,
              imageUrl: request.imageUrl != null ? Value(request.imageUrl!) : const Value.absent(),
              blurHash: request.blurHash != null ? Value(request.blurHash!) : const Value.absent(),
              minTemp: request.minTemp != null ? Value(request.minTemp!) : const Value.absent(),
              maxTemp: request.maxTemp != null ? Value(request.maxTemp!) : const Value.absent(),
              warmthLevel: request.warmthLevel != null ? Value(request.warmthLevel!) : const Value.absent(),
              rainOk: request.rainOk,
              snowOk: request.snowOk,
              windOk: request.windOk,
              usage: request.usage != null ? Value(request.usage!) : const Value.absent(),
              materials: request.materials != null ? Value(request.materials!) : const Value.absent(),
              wearCount: 0,
              lastWornAt: const Value.absent(),
              isFavorite: request.isFavorite,
              isArchived: request.isArchived,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              dirty: true, // Mark as dirty to sync back to server
              season: request.season != null ? Value(request.season!) : const Value.absent(),
              gender: request.gender != null ? Value(request.gender!) : const Value.absent(),
              fit: request.fit != null ? Value(request.fit!) : const Value.absent(),
              pattern: request.pattern != null ? Value(request.pattern!) : const Value.absent(),
              localImagePath: request.localImagePath != null ? Value(request.localImagePath!) : const Value.absent(),
            ));
            break;
          case 'wardrobe_update':
            // Parse the payload to WardrobeUpdateRequest
            final payload = json.decode(change.payload);
            final request = WardrobeItemUpdateRequest(
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

            await _db.wardrobeDao.updateOne(WardrobeEntriesCompanion(
              id: Value(change.entityId),
              name: request.name != null ? Value(request.name!) : const Value.absent(),
              category: request.category != null ? Value(request.category!) : const Value.absent(),
              subcategory: request.subcategory != null ? Value(request.subcategory!) : const Value.absent(),
              style: request.style != null ? Value(request.style!) : const Value.absent(),
              iconEmoji: request.iconEmoji != null ? Value(request.iconEmoji!) : const Value.absent(),
              imageUrl: request.imageUrl != null ? Value(request.imageUrl!) : const Value.absent(),
              blurHash: request.blurHash != null ? Value(request.blurHash!) : const Value.absent(),
              minTemp: request.minTemp != null ? Value(request.minTemp!) : const Value.absent(),
              maxTemp: request.maxTemp != null ? Value(request.maxTemp!) : const Value.absent(),
              warmthLevel: request.warmthLevel != null ? Value(request.warmthLevel!) : const Value.absent(),
              rainOk: request.rainOk != null ? Value(request.rainOk!) : const Value.absent(),
              snowOk: request.snowOk != null ? Value(request.snowOk!) : const Value.absent(),
              windOk: request.windOk != null ? Value(request.windOk!) : const Value.absent(),
              usage: request.usage != null ? Value(request.usage!) : const Value.absent(),
              materials: request.materials != null ? Value(request.materials!) : const Value.absent(),
              isFavorite: request.isFavorite != null ? Value(request.isFavorite!) : const Value.absent(),
              isArchived: request.isArchived != null ? Value(request.isArchived!) : const Value.absent(),
              season: request.season != null ? Value(request.season!) : const Value.absent(),
              gender: request.gender != null ? Value(request.gender!) : const Value.absent(),
              fit: request.fit != null ? Value(request.fit!) : const Value.absent(),
              pattern: request.pattern != null ? Value(request.pattern!) : const Value.absent(),
              localImagePath: request.localImagePath != null ? Value(request.localImagePath!) : const Value.absent(),
              lastWornAt: const Value.absent(), // Explicitly handle nullable DateTime
              updatedAt: Value(DateTime.now()),
              dirty: Value(true), // Mark as dirty to sync back
            ));
            break;
          case 'wardrobe_delete':
            await _db.wardrobeDao.deleteById(change.entityId);
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
            debugPrint('Unknown sync action: ${change.action}');
            continue; // Skip unknown actions
        }

        // Отмечаем, что синхронизация прошла успешно
        await _db.syncOutboxDao.markAsSynced(change.id);
      } catch (e, stackTrace) {
        // Логируем ошибку с деталями, но не прерываем синхронизацию других элементов
        debugPrint('Sync error for ${change.id} (${change.action}): $e');
        debugPrint('Stack trace: $stackTrace');

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
      debugPrint('Sync error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Метод для запуска периодической синхронизации
  Future<void> startPeriodicSync() async {
    // Проверяем подключение к интернету перед синхронизацией
    final connectivityResults = await Connectivity().checkConnectivity();

    if (connectivityResults.isNotEmpty && connectivityResults[0] != ConnectivityResult.none) {
      // Запускаем синхронизацию каждые 5 минут при наличии подключения
      _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
        await startSync();
      });
    }
  }

  /// Метод для синхронизации шкафа
  Future<void> syncWardrobe() async {
    try {
      final repo = WardrobeRepository(_db, _wardrobeRemote);
      await repo.syncFromServer();
    } catch (e, stackTrace) {
      debugPrint('Wardrobe sync error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Метод для синхронизации рекомендаций
  Future<void> syncRecommendations() async {
    try {
      final repo = RecommendationsRepository(_db, _recRemote);
      await repo.syncFromServer();
    } catch (e, stackTrace) {
      debugPrint('Recommendations sync error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Метод для остановки периодической синхронизации
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }
}
