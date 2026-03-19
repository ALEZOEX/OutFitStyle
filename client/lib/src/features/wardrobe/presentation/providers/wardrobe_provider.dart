import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../data/remote/wardrobe_api_service.dart';
import '../../../../domain/entities/catalog_entity.dart';
import '../../data/repositories/wardrobe_repository.dart';
import '../../../../domain/entities/wardrobe_item.dart';
import '../../../../domain/entities/wardrobe_request_entities.dart';
import '../../../../presentation/providers/session_provider.dart';
import '../../../../presentation/routing/router.dart';

/// Состояние гардероба
enum WardrobeLoadStatus { initial, loading, success, error }

/// Провайдер состояния гардероба
class WardrobeState {
  final List<WardrobeItem> items;
  final WardrobeLoadStatus status;
  final String? selectedCategory;
  final String? error;
  final bool isAddingItem;

  const WardrobeState({
    this.items = const [],
    this.status = WardrobeLoadStatus.initial,
    this.selectedCategory,
    this.error,
    this.isAddingItem = false,
  });

  WardrobeState copyWith({
    List<WardrobeItem>? items,
    WardrobeLoadStatus? status,
    String? selectedCategory,
    String? error,
    bool? isAddingItem,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      status: status ?? this.status,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error ?? this.error,
      isAddingItem: isAddingItem ?? this.isAddingItem,
    );
  }

  /// Получить отфильтрованные элементы по категории
  List<WardrobeItem> get filteredItems {
    if (selectedCategory == null || selectedCategory == 'all') {
      return items;
    }
    return items.where((item) => item.category == selectedCategory).toList();
  }

  /// Получить количество элементов по категориям
  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final item in items) {
      final category = item.category ?? 'other';
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// Получить общее количество элементов
  int get totalCount => items.length;

  /// Получить количество избранных элементов
  int get favoritesCount =>
      items.where((item) => item.isFavorite == true).length;
}

/// Провайдер WardrobeApiService
final wardrobeApiServiceProvider = Provider<WardrobeApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WardrobeApiService(apiClient: apiClient);
});

/// Провайдер WardrobeRepository
final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  final apiService = ref.watch(wardrobeApiServiceProvider);
  return WardrobeRepository(apiService: apiService);
});

/// Провайдер гардероба
final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>(
  (ref) {
    final repository = ref.watch(wardrobeRepositoryProvider);
    return WardrobeNotifier(repository: repository);
  },
);

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  final WardrobeRepository _repository;

  WardrobeNotifier({required WardrobeRepository repository})
    : _repository = repository,
      super(const WardrobeState()) {
    _loadWardrobe();
  }

  /// Загрузить гардероб с сервера
  Future<void> _loadWardrobe() async {
    state = state.copyWith(status: WardrobeLoadStatus.loading);

    try {
      final result = await _repository.getWardrobeItems(
        includeArchived: false,
        page: 1,
        limit: 100,
      );

      state = state.copyWith(
        items: result.items,
        status: WardrobeLoadStatus.success,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: WardrobeLoadStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Выбрать категорию для фильтрации
  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Переключить избранное
  Future<void> toggleFavorite(String itemId) async {
    final items = List<WardrobeItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == itemId);

    if (index == -1) return;

    final currentItem = items[index];
    final newIsFavorite = !(currentItem.isFavorite ?? false);

    // Оптимистичное обновление UI
    items[index] = currentItem.copyWith(isFavorite: newIsFavorite);
    state = state.copyWith(items: items);

    try {
      await _repository.toggleFavorite(itemId, newIsFavorite);
    } catch (e) {
      // Откат при ошибке
      items[index] = currentItem;
      state = state.copyWith(items: items);
    }
  }

  /// Добавить новый элемент через API
  Future<WardrobeItem?> addItem(WardrobeItemCreateRequest request) async {
    state = state.copyWith(isAddingItem: true, error: null);

    try {
      final newItem = await _repository.createWardrobeItem(request);

      // Добавляем в список
      final items = List<WardrobeItem>.from(state.items)..add(newItem);
      state = state.copyWith(items: items, isAddingItem: false);

      return newItem;
    } catch (e) {
      state = state.copyWith(isAddingItem: false, error: e.toString());
      rethrow;
    }
  }

  /// Удалить элемент
  Future<void> removeItem(String itemId) async {
    try {
      await _repository.deleteWardrobeItem(itemId);

      // Удаляем из списка
      final items = List<WardrobeItem>.from(state.items)
        ..removeWhere((item) => item.id == itemId);
      state = state.copyWith(items: items);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Обновить элемент
  Future<void> updateItem(
    String itemId,
    WardrobeItemUpdateRequest request,
  ) async {
    try {
      final updatedItem = await _repository.updateWardrobeItem(itemId, request);

      // Обновляем в списке
      final items = List<WardrobeItem>.from(state.items);
      final index = items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        items[index] = updatedItem;
        state = state.copyWith(items: items);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Перезагрузить данные
  Future<void> refresh() async {
    await _loadWardrobe();
  }

  /// Добавить вещь из каталога в гардероб
  ///
  /// Создает новую вещь в гардеробе на основе элемента каталога
  Future<WardrobeItem?> addItemFromCatalog(CatalogEntity catalogItem) async {
    state = state.copyWith(isAddingItem: true, error: null);

    try {
      // Получаем userId из хранилища
      // В реальном приложении userId должен быть доступен из auth-сервиса
      // Для упрощения используем заглушку - сервер сам определит пользователя по токену
      final request = WardrobeItemCreateRequest(
        name: catalogItem.name,
        category: catalogItem.category,
        subcategory: catalogItem.subcategory,
        style: catalogItem.style,
        iconEmoji: catalogItem.iconEmoji ?? catalogItem.categoryEmoji,
        imageUrl: catalogItem.imageUrl,
        minTemp: catalogItem.minTemp,
        maxTemp: catalogItem.maxTemp,
        warmthLevel: catalogItem.warmthLevel,
        rainOk: catalogItem.rainOk,
        snowOk: catalogItem.snowOk,
        windOk: catalogItem.windOk,
        isFavorite: false,
        isArchived: false,
        season: catalogItem.season,
        gender: catalogItem.gender,
        fit: catalogItem.fit,
        pattern: catalogItem.pattern,
        materials:
            catalogItem.materials.isNotEmpty
                ? catalogItem.materials.join(',')
                : null,
        usage: catalogItem.usage.isNotEmpty ? catalogItem.usage.first : null,
        userId: '', // Сервер определит по токену
        clothingItemId: catalogItem.id,
      );

      final newItem = await _repository.createWardrobeItem(request);

      // Добавляем в список
      final items = List<WardrobeItem>.from(state.items)..add(newItem);
      state = state.copyWith(items: items, isAddingItem: false);

      return newItem;
    } catch (e) {
      state = state.copyWith(isAddingItem: false, error: e.toString());
      rethrow;
    }
  }
}

/// Провайдер для получения отфильтрованных элементов
final filteredWardrobeItemsProvider = Provider<List<WardrobeItem>>((ref) {
  final state = ref.watch(wardrobeProvider);
  return state.filteredItems;
});

/// Провайдер для получения категорий с количеством
final wardrobeCategoriesProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(wardrobeProvider);
  return {'all': state.totalCount, ...state.categoryCounts};
});
