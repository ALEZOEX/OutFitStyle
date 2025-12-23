import 'dart:convert';

import '../local/app_database.dart';
import '../sync/outbox_actions.dart';
import '../remote/wardrobe_remote_ds.dart';
import '../remote/recommendation_remote_ds.dart';

class SyncWorker {
  final AppDatabase db;
  final WardrobeRemoteDataSource wardrobeRemote;
  final RecommendationRemoteDataSource recRemote;

  bool _running = false;

  SyncWorker({
    required this.db,
    required this.wardrobeRemote,
    required this.recRemote,
  });

  Future<void> runOnce({int batch = 20}) async {
    if (_running) return;
    _running = true;

    try {
      final due = await db.syncOutboxDao.takeDue(limit: batch);
      for (final job in due) {
        try {
          await _execute(job);
          await db.syncOutboxDao.markSuccess(job.localId);
        } catch (e) {
          final nextAttempts = job.attempts + 1;
          await db.syncOutboxDao.markFailed(job.localId, e.toString(), nextAttempts);
        }
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _execute(SyncOutboxRow job) async {
    final payload = (jsonDecode(job.payloadJson) as Map).cast<String, dynamic>();

    switch (job.type) {
      case OutboxActions.wardrobeSetFavorite:
        await wardrobeRemote.setFavorite(payload['id'] as String, payload['value'] as bool);
        return;

      case OutboxActions.wardrobeSetArchived:
        await wardrobeRemote.setArchived(payload['id'] as String, payload['value'] as bool);
        return;

      case OutboxActions.wardrobeWorn:
        await wardrobeRemote.worn(payload['id'] as String);
        return;

      case OutboxActions.recSetFavorite:
        await recRemote.setFavorite(
          id: payload['id'] as String,
          isFavorite: payload['value'] as bool,
        );
        return;

      case OutboxActions.outfitPublishLocal: {
        final localId = payload['local_id'] as String;
        final outfitJson = payload['outfit_data_json'] as String;
        final weatherJson = payload['weather_data_json'] as String;

        final serverId = await recRemote.publishCustomOutfit(
          outfitDataJson: outfitJson,
          weatherDataJson: weatherJson,
        );

        await db.recommendationDao.markPublished(localId: localId, serverId: serverId);
        return;
      }

      default:
        throw Exception('Unknown outbox action: ${job.type}');
    }
  }
}