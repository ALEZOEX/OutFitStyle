import 'package:outfitstyle_client/domain/entities/wardrobe.dart';
import 'package:outfitstyle_client/domain/repositories/i_wardrobe_repository.dart';

abstract class GetWardrobeItemsUsecase {
  Future<List<WardrobeItem>> call({String? userId});
}

class GetWardrobeItemsUsecaseImpl implements GetWardrobeItemsUsecase {
  final IWardrobeRepository _repository;

  GetWardrobeItemsUsecaseImpl(this._repository);

  @override
  Future<List<WardrobeItem>> call({String? userId}) async {
    return await _repository.getAllWardrobeItems(userId: userId);
  }
}

abstract class GetWardrobeItemByIdUsecase {
  Future<WardrobeItem?> call(String id);
}

class GetWardrobeItemByIdUsecaseImpl implements GetWardrobeItemByIdUsecase {
  final IWardrobeRepository _repository;

  GetWardrobeItemByIdUsecaseImpl(this._repository);

  @override
  Future<WardrobeItem?> call(String id) async {
    return await _repository.getWardrobeItemById(id);
  }
}

abstract class AddWardrobeItemUsecase {
  Future<WardrobeItem> call(WardrobeItem item);
}

class AddWardrobeItemUsecaseImpl implements AddWardrobeItemUsecase {
  final IWardrobeRepository _repository;

  AddWardrobeItemUsecaseImpl(this._repository);

  @override
  Future<WardrobeItem> call(WardrobeItem item) async {
    return await _repository.addWardrobeItem(item);
  }
}

abstract class UpdateWardrobeItemUsecase {
  Future<WardrobeItem> call(WardrobeItem item);
}

class UpdateWardrobeItemUsecaseImpl implements UpdateWardrobeItemUsecase {
  final IWardrobeRepository _repository;

  UpdateWardrobeItemUsecaseImpl(this._repository);

  @override
  Future<WardrobeItem> call(WardrobeItem item) async {
    return await _repository.updateWardrobeItem(item);
  }
}

abstract class DeleteWardrobeItemUsecase {
  Future<void> call(String id);
}

class DeleteWardrobeItemUsecaseImpl implements DeleteWardrobeItemUsecase {
  final IWardrobeRepository _repository;

  DeleteWardrobeItemUsecaseImpl(this._repository);

  @override
  Future<void> call(String id) async {
    return await _repository.deleteWardrobeItem(id);
  }
}

abstract class FilterWardrobeItemsUsecase {
  Future<List<WardrobeItem>> call({
    String? category,
    String? subcategory,
    String? color,
    String? brand,
    String? name,
    bool? isFavorite,
    bool? isArchived,
    String? userId,
    String? season,
    String? style,
    List<String>? occasions,
  });
}

class FilterWardrobeItemsUsecaseImpl implements FilterWardrobeItemsUsecase {
  final IWardrobeRepository _repository;

  FilterWardrobeItemsUsecaseImpl(this._repository);

  @override
  Future<List<WardrobeItem>> call({
    String? category,
    String? subcategory,
    String? color,
    String? brand,
    String? name,
    bool? isFavorite,
    bool? isArchived,
    String? userId,
    String? season,
    String? style,
    List<String>? occasions,
  }) async {
    return await _repository.filterWardrobeItems(
      category: category,
      subcategory: subcategory,
      color: color,
      brand: brand,
      name: name,
      isFavorite: isFavorite,
      isArchived: isArchived,
      userId: userId,
      season: season,
      style: style,
      occasions: occasions,
    );
  }
}