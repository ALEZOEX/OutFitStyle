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
      latest = null; // Сбрасываем, чтобы проверить свежесть
      total = 0;
    }

    isLoadingMore = true;
    notifyListeners();

    try {
      final (list, t) = await _svc.list(page: _page, limit: _limit);

      // Логика "Умной загрузки":
      if (refresh && list.isNotEmpty) {
        final firstRec = list.first;
        final now = DateTime.now();
        // Если последняя рекомендация была сегодня - используем её
        if (firstRec.createdAt.day == now.day &&
            firstRec.createdAt.month == now.month &&
            firstRec.createdAt.year == now.year) {
          latest = firstRec;
          // Если мы нашли latest в списке, удаляем его из истории, чтобы не дублировать
          if (list.isNotEmpty && list.first.id == latest!.id) {
            list.removeAt(0);
          }
        } else {
          // Иначе - она старая, генерируем новую (фоном)
          // (Запускаем createUsingProfile, но не ждем его, чтобы UI не вис)
          createUsingProfile();
        }
      } else if (refresh && list.isEmpty) {
        // Вообще нет истории -> генерируем первую
        createUsingProfile();
      }

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