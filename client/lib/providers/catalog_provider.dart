import 'package:flutter/foundation.dart';
import '../services/catalog_service.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogService _svc;
  CatalogProvider(this._svc);

  List<Map<String, dynamic>> items = [];
  bool isLoading = false;

  Future<void> load({String? query, String? category}) async {
    isLoading = true;
    notifyListeners();
    try {
      items = await _svc.search(query: query, category: category);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}