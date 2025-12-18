import '../models/recommendation_models.dart';
import 'api_service.dart';
import 'auth_storage.dart';

class RecommendationService {
  final ApiService _api;

  RecommendationService({
    required String baseUrl,
    required AuthStorage authStorage,
  }) : _api = ApiService(baseUrl: baseUrl, authStorage: authStorage);

  Future<RecommendationRecord> create({
    required double lat,
    required double lon,
    String? occasion,
    String? style,
    int? formality,
    bool includePartnerItems = false,
  }) async {
    final data = await _api.postJson('/recommendations', body: {
      'latitude': lat,
      'longitude': lon,
      if (occasion != null) 'occasion': occasion,
      if (style != null) 'style': style,
      if (formality != null) 'formality': formality,
      'include_partner_items': includePartnerItems,
    }) as Map<String, dynamic>;

    final rec = (data['recommendation'] as Map).cast<String, dynamic>();
    return RecommendationRecord.fromJson(rec);
  }

  Future<(List<RecommendationRecord>, int total)> list({
    int page = 1,
    int limit = 20,
    String? fromDate, // YYYY-MM-DD
    String? toDate,
    String? occasion,
    int? minRating,
    bool? isFavorite,
  }) async {
    final q = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (occasion != null) 'occasion': occasion,
      if (minRating != null) 'min_rating': '$minRating',
      if (isFavorite != null) 'is_favorite': isFavorite.toString(),
    };

    final data = await _api.getJson('/recommendations', query: q) as Map<String, dynamic>;
    final listJson = (data['recommendations'] as List).cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
    final items = listJson.map(RecommendationRecord.fromJson).toList();

    final pagination = (data['pagination'] as Map?)?.cast<String, dynamic>() ?? {};
    final total = (pagination['total'] ?? items.length) as int;

    return (items, total);
  }

  Future<void> rate({
    required String recommendationId,
    required int rating,
    String? thermalFeedback,
    String? feedback,
  }) async {
    await _api.postJson('/recommendations/$recommendationId/rate', body: {
      'rating': rating,
      if (thermalFeedback != null) 'thermal_feedback': thermalFeedback,
      if (feedback != null) 'feedback': feedback,
    });
  }

  Future<void> setFavorite({required String recommendationId, required bool isFavorite}) async {
    await _api.postJson('/recommendations/$recommendationId/favorite', body: {'is_favorite': isFavorite});
  }

  Future<RecommendationRecord> createUsingProfile({String? occasion, String? style, int? formality}) async {
    final data = await _api.postJson('/recommendations', body: {
      if (occasion != null) 'occasion': occasion,
      if (style != null) 'style': style,
      if (formality != null) 'formality': formality,
    }) as Map<String, dynamic>;

    final rec = (data['recommendation'] as Map).cast<String, dynamic>();
    return RecommendationRecord.fromJson(rec);
  }

  Future<RecommendationRecord> regenerate({
    required String recommendationId,
    List<String>? excludeItems,
    String? preferStyle,
  }) async {
    final data = await _api.postJson('/recommendations/$recommendationId/regenerate', body: {
      if (excludeItems != null) 'exclude_items': excludeItems,
      if (preferStyle != null) 'prefer_style': preferStyle,
    }) as Map<String, dynamic>;

    final rec = (data['recommendation'] as Map).cast<String, dynamic>();
    return RecommendationRecord.fromJson(rec);
  }
}