import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/wardrobe_item.dart';

/// Пустой гардероб пользователя (изначально пуст)

/// Состояние гардероба
enum WardrobeLoadStatus {
  initial,
  loading,
  success,
  error,
}

/// Провайдер состояния гардероба
class WardrobeState {
  final List<WardrobeItem> items;
  final WardrobeLoadStatus status;
  final String? selectedCategory;
  final String? error;

  const WardrobeState({
    this.items = const [],
    this.status = WardrobeLoadStatus.initial,
    this.selectedCategory,
    this.error,
  });

  WardrobeState copyWith({
    List<WardrobeItem>? items,
    WardrobeLoadStatus? status,
    String? selectedCategory,
    String? error,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      status: status ?? this.status,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      error: error ?? this.error,
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
  int get favoritesCount => items.where((item) => item.isFavorite == true).length;
}

/// Провайдер гардероба
final wardrobeProvider = StateNotifierProvider<WardrobeNotifier, WardrobeState>((ref) {
  return WardrobeNotifier();
});

class WardrobeNotifier extends StateNotifier<WardrobeState> {
  WardrobeNotifier() : super(const WardrobeState()) {
    _loadWardrobe();
  }

  /// Загрузить гардероб (пустой изначально)
  Future<void> _loadWardrobe() async {
    state = state.copyWith(status: WardrobeLoadStatus.loading);

    try {
      // Имитация задержки загрузки
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        items: [], // Пустой гардероб изначально
        status: WardrobeLoadStatus.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: WardrobeLoadStatus.error,
        error: 'Ошибка загрузки: $e',
      );
    }
  }

  /// Выбрать категорию для фильтрации
  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Переключить избранное
  void toggleFavorite(String itemId) {
    final items = List<WardrobeItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == itemId);
    
    if (index != -1) {
      items[index] = items[index].copyWith(
        isFavorite: !(items[index].isFavorite ?? false),
      );
      state = state.copyWith(items: items);
    }
  }

  /// Добавить новый элемент
  void addItem(WardrobeItem item) {
    final items = List<WardrobeItem>.from(state.items)..add(item);
    state = state.copyWith(items: items);
  }

  /// Удалить элемент
  void removeItem(String itemId) {
    final items = List<WardrobeItem>.from(state.items)..removeWhere((item) => item.id == itemId);
    state = state.copyWith(items: items);
  }

  /// Обновить элемент
  void updateItem(WardrobeItem item) {
    final items = List<WardrobeItem>.from(state.items);
    final index = items.indexWhere((item) => item.id == item.id);
    
    if (index != -1) {
      items[index] = item;
      state = state.copyWith(items: items);
    }
  }

  /// Перезагрузить данные
  Future<void> refresh() async {
    await _loadWardrobe();
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
  return {
    'all': state.totalCount,
    ...state.categoryCounts,
  };
});
