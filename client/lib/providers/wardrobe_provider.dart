import 'package:flutter/foundation.dart';
import '../models/wardrobe_models.dart';
import '../services/wardrobe_service.dart';

class WardrobeProvider extends ChangeNotifier {
  final WardrobeService _svc;

  WardrobeProvider(this._svc);

  final List<WardrobeItem> items = [];
  int total = 0;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;

  int _page = 1;
  final int _limit = 20;
  bool get hasMore => items.length < total;

  Future<void> refresh() async {
    error = null;
    isLoading = true;
    notifyListeners();

    try {
      _page = 1;
      final (list, t) = await _svc.list(page: _page, limit: _limit);
      items
        ..clear()
        ..addAll(list);
      total = t;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      _page += 1;
      final (list, t) = await _svc.list(page: _page, limit: _limit);
      items.addAll(list);
      total = t;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(WardrobeItem item) async {
    final idx = items.indexWhere((x) => x.id == item.id);
    if (idx < 0) return;

    final newValue = !items[idx].isFavorite;
    try {
      await _svc.setFavorite(item.id, newValue);
      // локально обновим (простое решение: перезагрузить страницу)
      await refresh();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleArchive(WardrobeItem item) async {
    final idx = items.indexWhere((x) => x.id == item.id);
    if (idx < 0) return;

    final newValue = !items[idx].isArchived;
    try {
      await _svc.setArchived(item.id, newValue);
      await refresh();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markWorn(WardrobeItem item) async {
    try {
      await _svc.worn(item.id);
      await refresh();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addManual({
    required String name,
    required String category,
    required String subcategory,
    required String style,
  }) async {
    try {
      await _svc.createManual(
        name: name,
        category: category,
        subcategory: subcategory,
        style: style,
      );
      await refresh();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}