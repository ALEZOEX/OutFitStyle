import 'package:outfitstyle_client/services/wardrobe_service.dart';
import 'package:outfitstyle_client/models/wardrobe_models.dart' as api_models;

class WardrobeRemoteDataSource {
  final WardrobeService _svc;
  WardrobeRemoteDataSource(this._svc);

  Future<List<api_models.WardrobeItemResponse>> fetchAll() async {
    // тянем постранично, пока есть
    final result = <api_models.WardrobeItemResponse>[];
    var page = 1;
    const limit = 50;

    while (true) {
      final (list, total) = await _svc.list(page: page, limit: limit);
      result.addAll(list);
      if (result.length >= total) break;
      if (list.isEmpty) break;
      page += 1;
    }

    return result;
  }

  Future<void> setFavorite(String id, bool value) => _svc.setFavorite(id, value);
  Future<void> setArchived(String id, bool value) => _svc.setArchived(id, value);
  Future<void> worn(String id) => _svc.worn(id);
}