import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/domain/entities/wardrobe_item.dart';
import 'package:outfitstyle_client/domain/services/wardrobe_domain_service.dart';
import 'package:outfitstyle_client/domain/states/wardrobe_state.dart';

class WardrobeController extends StateNotifier<WardrobeState> {
  final Ref _ref;

  WardrobeController(this._ref) : super(WardrobeInitial());

  Future<void> loadWardrobe() async {
    state = WardrobeLoading();
    try {
      final service = _ref.read(wardrobeDomainServiceProvider);
      final items = await service.getAllWardrobeItems();
      state = WardrobeLoaded(items);
    } catch (e) {
      state = WardrobeError(e.toString());
    }
  }

  Future<void> addItem(WardrobeItem item) async {
    try {
      final service = _ref.read(wardrobeDomainServiceProvider);
      await service.addWardrobeItem(item);
      // Reload the wardrobe to reflect the changes
      await loadWardrobe();
    } catch (e) {
      state = WardrobeError(e.toString());
    }
  }

  Future<void> updateItem(WardrobeItem item) async {
    try {
      final service = _ref.read(wardrobeDomainServiceProvider);
      await service.updateWardrobeItem(item);
      // Reload the wardrobe to reflect the changes
      await loadWardrobe();
    } catch (e) {
      state = WardrobeError(e.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final service = _ref.read(wardrobeDomainServiceProvider);
      await service.deleteWardrobeItem(id);
      // Reload the wardrobe to reflect the changes
      await loadWardrobe();
    } catch (e) {
      state = WardrobeError(e.toString());
    }
  }
}