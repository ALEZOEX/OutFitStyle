import 'package:outfitstyle_client/services/wardrobe_service.dart';
import 'package:outfitstyle_client/models/wardrobe_models.dart' as api_models;

class WardrobeRemoteDataSource {
  final WardrobeService _svc;
  WardrobeRemoteDataSource(this._svc);

  Future<List<api_models.WardrobeItem>> fetchAll() async {
    // тянем постранично, пока есть
    final result = <api_models.WardrobeItem>[];
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

  Future<api_models.WardrobeItem> create(api_models.WardrobeCreateRequest request) async {
    return await _svc.create(request);
  }

  Future<api_models.WardrobeItem> update(String id, api_models.WardrobeUpdateRequest request) async {
    return await _svc.update(id, request);
  }

  Future<void> delete(String id) async {
    return await _svc.delete(id);
  }

  Future<void> setFavorite(String id, bool value) => _svc.setFavorite(id, value);
  Future<void> setArchived(String id, bool value) => _svc.setArchived(id, value);
  Future<void> worn(String id) => _svc.worn(id);
  Future<api_models.WardrobeItem> getById(String id) async => await _svc.getById(id);
}