import 'package:flutter/foundation.dart';
import '../models/recommendation_models.dart';
import '../services/recommendation_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _svc;

  RecommendationProvider(this._svc);

  RecommendationRecord? latest;
  final List<RecommendationRecord> history = [];
  int total = 0;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;

  int _page = 1;
  final int _limit = 20;
  bool get hasMore => history.length < total;

  Future<void> create({
    required double lat,
    required double lon,
    String? occasion,
  }) async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      latest = await _svc.create(lat: lat, lon: lon, occasion: occasion);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory({bool refresh = false}) async {
    if (isLoading || isLoadingMore) return;

    if (refresh) {
      _page = 1;
      history.clear();
      total = 0;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final (list, t) = await _svc.list(page: _page, limit: _limit);
      history.addAll(list);
      total = t;
      _page += 1;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> rateLatest(int rating) async {
    final rec = latest;
    if (rec == null) return;

    try {
      await _svc.rate(recommendationId: rec.id, rating: rating);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(RecommendationRecord rec) async {
    try {
      await _svc.setFavorite(recommendationId: rec.id, isFavorite: !rec.isFavorite);
      await loadHistory(refresh: true);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createUsingProfile({String occasion = 'daily'}) async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      latest = await _svc.createUsingProfile(occasion: occasion);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}