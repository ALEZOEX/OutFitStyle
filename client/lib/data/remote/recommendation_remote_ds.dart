import 'package:outfitstyle_client/models/recommendation_models.dart';
import 'package:outfitstyle_client/services/recommendation_service.dart';

class RecommendationRemoteDataSource {
  final RecommendationService _svc;
  RecommendationRemoteDataSource(this._svc);

  Future<RecommendationRecord> createUsingProfile({required String occasion}) {
    return _svc.createUsingProfile(occasion: occasion);
  }

  Future<(List<RecommendationRecord>, int total)> list({required int page, required int limit}) {
    return _svc.list(page: page, limit: limit);
  }

  Future<void> setFavorite({required String id, required bool isFavorite}) {
    return _svc.setFavorite(recommendationId: id, isFavorite: isFavorite);
  }

  /// Требуется endpoint на backend, который принимает outfit_data + weather_data
  /// и возвращает server uuid созданной рекомендации/образа.
  Future<String> publishCustomOutfit({
    required String outfitDataJson,
    required String weatherDataJson,
  }) async {
    // В идеале тут будет реальный API вызов.
    // Пока backend не поддерживает — бросаем, и outbox ретраит/хранит локально.
    throw UnimplementedError('Backend endpoint for publishCustomOutfit is not implemented');
  }
}