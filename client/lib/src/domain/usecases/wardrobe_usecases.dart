import '../entities/wardrobe_item.dart';
import '../repositories/i_wardrobe_repository.dart';

abstract class GetWardrobeItemsUsecase {
  Future<List<WardrobeItem>> call();
}

class GetWardrobeItemsUsecaseImpl implements GetWardrobeItemsUsecase {
  final IWardrobeRepository _repository;

  GetWardrobeItemsUsecaseImpl(this._repository);

  @override
  Future<List<WardrobeItem>> call() async {
    return await _repository.getAllWardrobeItems();
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
  Future<void> call(WardrobeItem item);
}

class AddWardrobeItemUsecaseImpl implements AddWardrobeItemUsecase {
  final IWardrobeRepository _repository;

  AddWardrobeItemUsecaseImpl(this._repository);

  @override
  Future<void> call(WardrobeItem item) async {
    return await _repository.addWardrobeItem(item);
  }
}

abstract class UpdateWardrobeItemUsecase {
  Future<void> call(WardrobeItem item);
}

class UpdateWardrobeItemUsecaseImpl implements UpdateWardrobeItemUsecase {
  final IWardrobeRepository _repository;

  UpdateWardrobeItemUsecaseImpl(this._repository);

  @override
  Future<void> call(WardrobeItem item) async {
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