import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/wardrobe_item.dart';

/// Mock данные для гардероба
final mockWardrobeItems = <WardrobeItem>[
  const WardrobeItem(
    id: '1',
    name: 'Белая футболка Basic',
    category: 'top',
    subcategory: 'tshirt',
    brand: 'Uniqlo',
    color: 'белый',
    size: 'M',
    imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
    minTemp: 15,
    maxTemp: 30,
    isFavorite: true,
    style: 'casual',
  ),
  const WardrobeItem(
    id: '2',
    name: 'Джинсы Slim Fit',
    category: 'bottom',
    subcategory: 'jeans',
    brand: 'Levi\'s',
    color: 'синий',
    size: '32',
    imageUrl: 'https://images.unsplash.com/photo-1542272454315-4c01d7abdf4a?w=400',
    minTemp: 5,
    maxTemp: 25,
    isFavorite: false,
    style: 'casual',
  ),
  const WardrobeItem(
    id: '3',
    name: 'Кроссовки белые',
    category: 'shoes',
    subcategory: 'sneakers',
    brand: 'Nike',
    color: 'белый',
    size: '42',
    imageUrl: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400',
    minTemp: 10,
    maxTemp: 30,
    isFavorite: true,
    style: 'sport',
  ),
  const WardrobeItem(
    id: '4',
    name: 'Худи серое',
    category: 'top',
    subcategory: 'hoodie',
    brand: 'Champion',
    color: 'серый',
    size: 'L',
    imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?w=400',
    minTemp: 5,
    maxTemp: 18,
    isFavorite: false,
    style: 'casual',
  ),
  const WardrobeItem(
    id: '5',
    name: 'Куртка зимняя',
    category: 'outerwear',
    subcategory: 'jacket',
    brand: 'The North Face',
    color: 'черный',
    size: 'M',
    imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
    minTemp: -10,
    maxTemp: 10,
    isFavorite: true,
    style: 'outdoor',
  ),
  const WardrobeItem(
    id: '6',
    name: 'Шапка вязаная',
    category: 'headwear',
    subcategory: 'beanie',
    brand: 'Carhartt',
    color: 'черный',
    size: 'One Size',
    imageUrl: 'https://images.unsplash.com/photo-1576871337632-b9aef4c17ab9?w=400',
    minTemp: -5,
    maxTemp: 10,
    isFavorite: false,
    style: 'casual',
  ),
  const WardrobeItem(
    id: '7',
    name: 'Шарф шерстяной',
    category: 'accessory',
    subcategory: 'scarf',
    brand: 'Zara',
    color: 'бежевый',
    size: 'One Size',
    imageUrl: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=400',
    minTemp: -5,
    maxTemp: 15,
    isFavorite: false,
    style: 'classic',
  ),
  const WardrobeItem(
    id: '8',
    name: 'Рубашка оксфорд',
    category: 'top',
    subcategory: 'shirt',
    brand: 'Ralph Lauren',
    color: 'голубой',
    size: 'M',
    imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
    minTemp: 10,
    maxTemp: 25,
    isFavorite: true,
    style: 'classic',
  ),
  const WardrobeItem(
    id: '9',
    name: 'Ботинки кожаные',
    category: 'shoes',
    subcategory: 'boots',
    brand: 'Timberland',
    color: 'коричневый',
    size: '42',
    imageUrl: 'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400',
    minTemp: 0,
    maxTemp: 15,
    rainOk: true,
    isFavorite: false,
    style: 'casual',
  ),
  const WardrobeItem(
    id: '10',
    name: 'Пальто шерстяное',
    category: 'outerwear',
    subcategory: 'coat',
    brand: 'Hugo Boss',
    color: 'серый',
    size: 'M',
    imageUrl: 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400',
    minTemp: -5,
    maxTemp: 12,
    isFavorite: true,
    style: 'classic',
  ),
  const WardrobeItem(
    id: '11',
    name: 'Шорты летние',
    category: 'bottom',
    subcategory: 'shorts',
    brand: 'H&M',
    color: 'бежевый',
    size: 'M',
    imageUrl: 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=400',
    minTemp: 20,
    maxTemp: 35,
    isFavorite: false,
    style: 'casual',
  ),
  const WardrobeItem(
    id: '12',
    name: 'Кепка бейсбольная',
    category: 'headwear',
    subcategory: 'cap',
    brand: 'New Era',
    color: 'синий',
    size: 'One Size',
    imageUrl: 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=400',
    minTemp: 15,
    maxTemp: 35,
    isFavorite: false,
    style: 'sport',
  ),
];

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

  /// Загрузить гардероб (с mock данными)
  Future<void> _loadWardrobe() async {
    state = state.copyWith(status: WardrobeLoadStatus.loading);
    
    try {
      // Имитация задержки загрузки
      await Future.delayed(const Duration(milliseconds: 800));
      
      state = state.copyWith(
        items: mockWardrobeItems,
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
