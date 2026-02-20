import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_config.dart';
import '../../../../../data/remote/catalog_api_service.dart';
import '../../../../../services/auth_storage.dart';
import '../../../../domain/entities/catalog_entity.dart';
import '../providers/wardrobe_provider.dart';

/// Экран выбора вещи из каталога
///
/// Позволяет пользователю:
/// - Просматривать каталог вещей
/// - Искать по каталогу
/// - Фильтровать по категориям
/// - Просматривать детали вещи
/// - Добавлять вещь в гардероб
class CatalogSelectionScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const CatalogSelectionScreen({
    super.key,
    this.initialCategory,
  });

  @override
  ConsumerState<CatalogSelectionScreen> createState() => _CatalogSelectionScreenState();
}

class _CatalogSelectionScreenState extends ConsumerState<CatalogSelectionScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSubcategory;
  int _currentPage = 1;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogSelectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбрать из каталога'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Фильтры',
          ),
        ],
      ),
      body: Column(
        children: [
          // Поисковая строка
          _buildSearchBar(context),
          // Фильтры по категориям
          _buildCategoryChips(context),
          // Список вещей
          Expanded(
            child: _buildCatalogGrid(context, catalogState),
          ),
        ],
      ),
    );
  }

  /// Поисковая строка
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск вещей...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadCatalog();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {});
        },
        onSubmitted: (value) {
          _loadCatalog();
        },
      ),
    );
  }

  /// Чипсы категорий
  Widget _buildCategoryChips(BuildContext context) {
    final categories = [
      {'value': null, 'label': 'Все', 'emoji': '📋'},
      {'value': 'outerwear', 'label': 'Верхняя одежда', 'emoji': '🧥'},
      {'value': 'upper', 'label': 'Верх', 'emoji': '👕'},
      {'value': 'lower', 'label': 'Низ', 'emoji': '👖'},
      {'value': 'footwear', 'label': 'Обувь', 'emoji': '👟'},
      {'value': 'accessory', 'label': 'Аксессуары', 'emoji': '🧣'},
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['value'];
          return FilterChip(
            label: Text('${category['emoji']} ${category['label']}'),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? category['value'] as String? : null;
                _currentPage = 1;
              });
              _loadCatalog();
            },
          );
        },
      ),
    );
  }

  /// Сетка каталога
  Widget _buildCatalogGrid(BuildContext context, CatalogSelectionState catalogState) {
    if (catalogState.status == CatalogLoadStatus.loading && catalogState.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (catalogState.status == CatalogLoadStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки каталога',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              catalogState.error ?? 'Неизвестная ошибка',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadCatalog,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (catalogState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Каталог пуст',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить параметры поиска',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        await _loadCatalog();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: catalogState.items.length + (catalogState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == catalogState.items.length) {
            // Индикатор загрузки для бесконечной прокрутки
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final item = catalogState.items[index];
          return _buildCatalogItemCard(context, item);
        },
      ),
    );
  }

  /// Карточка вещи каталога
  Widget _buildCatalogItemCard(BuildContext context, CatalogEntity item) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showItemDetails(context, item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение или эмодзи
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            item.iconEmoji ?? item.categoryEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          item.iconEmoji ?? item.categoryEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
              ),
            ),
            // Информация о вещи
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.categoryDisplayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.temperatureRange != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.temperatureRange!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Показать детали вещи
  void _showItemDetails(BuildContext context, CatalogEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ItemDetailsSheet(item: item),
    );
  }

  /// Показать фильтр
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Фильтры',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Здесь можно добавить дополнительные фильтры
            const Text('Дополнительные фильтры в разработке...'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Загрузить каталог
  Future<void> _loadCatalog() async {
    await ref.read(catalogSelectionProvider.notifier).loadCatalog(
          query: _searchController.text.isEmpty ? null : _searchController.text,
          category: _selectedCategory,
          page: _currentPage,
          limit: _pageSize,
        );
  }
}

/// Bottom sheet с деталями вещи
class _ItemDetailsSheet extends ConsumerWidget {
  final CatalogEntity item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          // Заголовок
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Изображение
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        item.iconEmoji ?? item.categoryEmoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          // Название
          Text(
            item.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Категория
          Center(
            child: Chip(
              label: Text(item.categoryDisplayName),
              avatar: Text(item.categoryEmoji),
            ),
          ),
          const SizedBox(height: 24),
          // Характеристики
          _buildInfoSection(context, 'Характеристики', [
            if (item.temperatureRange != null)
              _buildInfoRow('Температура', item.temperatureRange!),
            if (item.warmthLevel != null)
              _buildInfoRow('Теплота', '${item.warmthLevel}/10'),
            _buildInfoRow('Сезон', item.seasonDisplayName),
            _buildInfoRow('Стиль', item.styleDisplayName),
            if (item.materials.isNotEmpty)
              _buildInfoRow('Материалы', item.materials.join(', ')),
          ]),
          const SizedBox(height: 16),
          // Погодные условия
          _buildInfoSection(context, 'Погодные условия', [
            _buildConditionRow('Дождь', item.rainOk),
            _buildConditionRow('Снег', item.snowOk),
            _buildConditionRow('Ветер', item.windOk),
          ]),
          const SizedBox(height: 32),
          // Кнопка добавления
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(catalogSelectionProvider);
                return FilledButton.icon(
                  onPressed: state.isAdding
                      ? null
                      : () => _addItemToWardrobe(context, ref),
                  icon: state.isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(state.isAdding ? 'Добавление...' : 'Добавить в гардероб'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Кнопка закрытия
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionRow(String label, bool condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            condition ? Icons.check_circle : Icons.cancel,
            color: condition ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Добавить вещь в гардероб
  Future<void> _addItemToWardrobe(BuildContext context, WidgetRef ref) async {
    try {
      final notifier = ref.read(catalogSelectionProvider.notifier);
      await notifier.addItemToWardrobe(item.id);

      if (context.mounted) {
        Navigator.pop(context); // Закрыть детали
        Navigator.pop(context); // Закрыть экран каталога

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вещь добавлена в гардероб'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Состояние экрана выбора каталога
enum CatalogLoadStatus {
  initial,
  loading,
  success,
  error,
}

/// Провайдер состояния выбора каталога
class CatalogSelectionState {
  final List<CatalogEntity> items;
  final CatalogLoadStatus status;
  final String? error;
  final bool isAdding;
  final int currentPage;
  final int totalItems;

  const CatalogSelectionState({
    this.items = const [],
    this.status = CatalogLoadStatus.initial,
    this.error,
    this.isAdding = false,
    this.currentPage = 1,
    this.totalItems = 0,
  });

  CatalogSelectionState copyWith({
    List<CatalogEntity>? items,
    CatalogLoadStatus? status,
    String? error,
    bool? isAdding,
    int? currentPage,
    int? totalItems,
  }) {
    return CatalogSelectionState(
      items: items ?? this.items,
      status: status ?? this.status,
      error: error ?? this.error,
      isAdding: isAdding ?? this.isAdding,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  bool get hasMore => items.length < totalItems;
}

/// Провайдер для экрана выбора каталога
final catalogSelectionProvider = StateNotifierProvider<CatalogSelectionNotifier, CatalogSelectionState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final catalogApiService = CatalogApiService(apiClient: apiClient);
  final wardrobeNotifier = ref.watch(wardrobeProvider.notifier);
  return CatalogSelectionNotifier(
    catalogApiService: catalogApiService,
    wardrobeNotifier: wardrobeNotifier,
  );
});

class CatalogSelectionNotifier extends StateNotifier<CatalogSelectionState> {
  final CatalogApiService _catalogApiService;
  final WardrobeNotifier _wardrobeNotifier;

  CatalogSelectionNotifier({
    required CatalogApiService catalogApiService,
    required WardrobeNotifier wardrobeNotifier,
  })  : _catalogApiService = catalogApiService,
        _wardrobeNotifier = wardrobeNotifier,
        super(const CatalogSelectionState()) {
    loadCatalog();
  }

  /// Загрузить каталог
  Future<void> loadCatalog({
    String? query,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    if (page == 1) {
      state = state.copyWith(status: CatalogLoadStatus.loading, error: null);
    }

    try {
      final response = await _catalogApiService.getCatalogItems(
        query: query,
        category: category,
        page: page,
        limit: limit,
      );

      final newItems = page == 1
          ? response.items
          : [...state.items, ...response.items];

      state = state.copyWith(
        items: newItems,
        status: CatalogLoadStatus.success,
        currentPage: page,
        totalItems: response.total,
      );
    } catch (e) {
      state = state.copyWith(
        status: CatalogLoadStatus.error,
        error: e.toString(),
      );
    }
  }

  /// Добавить вещь из каталога в гардероб
  Future<void> addItemToWardrobe(String catalogItemId) async {
    state = state.copyWith(isAdding: true);

    try {
      // Получаем детальную информацию о вещи
      final item = await _catalogApiService.getCatalogItem(catalogItemId);

      // Добавляем в гардероб через WardrobeNotifier
      await _wardrobeNotifier.addItemFromCatalog(item);

      state = state.copyWith(isAdding: false);
    } catch (e) {
      state = state.copyWith(
        isAdding: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Обновить страницу (сбросить и загрузить заново)
  Future<void> refresh() async {
    await loadCatalog(
      category: state.items.firstOrNull?.category,
      page: 1,
    );
  }
}
