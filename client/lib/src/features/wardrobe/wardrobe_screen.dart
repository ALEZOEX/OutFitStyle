import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/enums/clothing_category.dart';
import '../../domain/enums/clothing_season.dart';
import '../../domain/enums/clothing_weather.dart';
import '../../domain/enums/outfit_occasion.dart';
import '../../domain/enums/outfit_season.dart';
import '../../domain/enums/outfit_weather.dart';
import '../../presentation/providers/presentation_providers_exports.dart';
import '../../presentation/providers/repository_providers.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = [
    'Все',
    'Верх',
    'Низ',
    'Обувь',
    'Аксессуары',
    'Образы'
  ];
  final List<String> _filterOptions = ['Все', 'Любимое', 'Новое', 'По сезону'];
  String _currentFilter = 'Все';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    // Load wardrobe items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWardrobeItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWardrobeItems() async {
    // In a real app, this would fetch from repository
    // For now, we'll simulate loading
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditItemDialog(
        onSave: (item) {
          // Save the new item to repository
          if (item.id?.isEmpty ?? true) {
            ref.read(wardrobeRepositoryProvider).addClothingItem(item);
          } else {
            ref.read(wardrobeRepositoryProvider).updateClothingItem(item);
          }
          Navigator.of(context).pop();
        },
        clothingItem: const ClothingItem(),
        isEditing: false,
      ),
    );
  }

  void _showEditItemDialog(ClothingItem item) {
    showDialog(
      context: context,
      builder: (context) => AddEditItemDialog(
        onSave: (updatedItem) {
          // Update the item in repository
          if (updatedItem.id?.isEmpty ?? true) {
            ref.read(wardrobeRepositoryProvider).addClothingItem(updatedItem);
          } else {
            ref
                .read(wardrobeRepositoryProvider)
                .updateClothingItem(updatedItem);
          }
          Navigator.of(context).pop();
        },
        clothingItem: item,
        isEditing: true,
      ),
    );
  }

  void _showAddOutfitDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditOutfitDialog(
        onSave: (outfit) {
          // Save the new outfit to repository
          if (outfit.id?.isEmpty ?? true) {
            ref.read(wardrobeRepositoryProvider).createOutfit(outfit);
          } else {
            ref.read(wardrobeRepositoryProvider).updateOutfit(outfit);
          }
          Navigator.of(context).pop();
        },
        outfit: const Outfit(),
        isEditing: false,
      ),
    );
  }

  void _showEditOutfitDialog(Outfit outfit) {
    showDialog(
      context: context,
      builder: (context) => AddEditOutfitDialog(
        onSave: (updatedOutfit) {
          // Update the outfit in repository
          if (updatedOutfit.id?.isEmpty ?? true) {
            ref.read(wardrobeRepositoryProvider).createOutfit(updatedOutfit);
          } else {
            ref.read(wardrobeRepositoryProvider).updateOutfit(updatedOutfit);
          }
          Navigator.of(context).pop();
        },
        outfit: outfit,
        isEditing: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой гардероб'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String result) {
              setState(() {
                _currentFilter = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                _filterOptions.map((String option) {
              return PopupMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search functionality
              showSearch(
                context: context,
                delegate: WardrobeSearchDelegate(ref),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Show add item dialog based on current tab
              final currentIndex = _tabController.index;
              if (currentIndex == _categories.indexOf('Образы')) {
                _showAddOutfitDialog();
              } else {
                _showAddItemDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _categories.map((category) => Tab(text: category)).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                return _buildCategoryContent(category);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new item based on current tab
          final currentIndex = _tabController.index;
          if (currentIndex == _categories.indexOf('Образы')) {
            _showAddOutfitDialog();
          } else {
            _showAddItemDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildCategoryContent(String category) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh wardrobe items
        _loadWardrobeItems();
      },
      child: Consumer(
        builder: (context, ref, child) {
          final wardrobeRepo = ref.watch(wardrobeRepositoryProvider);

          switch (category) {
            case 'Образы':
              final outfitsFuture = ref.watch(wardrobeRepositoryProvider
                  .select((repo) => repo.getOutfits()));
              return outfitsFuture.when(
                data: (outfits) {
                  final filteredOutfits = _applyOutfitFilters(outfits);
                  return _buildOutfitsGrid(filteredOutfits);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Ошибка: $error')),
              );
            default:
              final itemsFuture = ref.watch(wardrobeRepositoryProvider
                  .select((repo) => repo.getClothingItems()));
              return itemsFuture.when(
                data: (items) {
                  final filteredItems = _applyItemFilters(items, category);
                  return _buildItemsGrid(filteredItems, category);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Ошибка: $error')),
              );
          }
        },
      ),
    );
  }

  List<ClothingItem> _applyItemFilters(
      List<ClothingItem> items, String category) {
    var filtered = items;

    // Apply category filter
    if (category != 'Все') {
      final categoryEnum = _getCategoryEnum(category);
      filtered =
          filtered.where((item) => item.category == categoryEnum).toList();
    }

    // Apply additional filters
    switch (_currentFilter) {
      case 'Любимое':
        filtered = filtered.where((item) => item.isFavorite).toList();
        break;
      case 'Новое':
        // Filter items added in the last 7 days
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered
            .where((item) =>
                item.addedDate != null && item.addedDate!.isAfter(weekAgo))
            .toList();
        break;
      case 'По сезону':
        // Filter items for current season (simplified)
        final currentMonth = DateTime.now().month;
        final currentSeason = _getCurrentSeason(currentMonth);
        filtered = filtered
            .where((item) =>
                item.seasons.contains(currentSeason) ||
                item.seasons.contains(ClothingSeason.allSeason))
            .toList();
        break;
    }

    return filtered;
  }

  List<Outfit> _applyOutfitFilters(List<Outfit> outfits) {
    var filtered = outfits;

    // Apply additional filters
    switch (_currentFilter) {
      case 'Любимое':
        filtered = filtered.where((outfit) => outfit.isFavorite).toList();
        break;
      case 'Новое':
        // Filter outfits added in the last 7 days
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered
            .where((outfit) =>
                outfit.addedDate != null && outfit.addedDate!.isAfter(weekAgo))
            .toList();
        break;
      case 'По сезону':
        // Filter outfits for current season (simplified)
        final currentMonth = DateTime.now().month;
        final currentSeason = _getCurrentSeason(currentMonth);
        filtered = filtered
            .where((outfit) =>
                outfit.seasons.contains(currentSeason) ||
                outfit.seasons.contains(OutfitSeason.allSeason))
            .toList();
        break;
    }

    return filtered;
  }

  Widget _buildItemsGrid(List<ClothingItem> items, String category) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет предметов в гардеробе',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте $category в свой гардероб',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return _buildWardrobeItem(item, category);
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitsGrid(List<Outfit> outfits) {
    if (outfits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет созданных образов',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте свой первый образ',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final outfit = outfits[index];
                return _buildOutfitItem(outfit);
              },
              childCount: outfits.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWardrobeItem(ClothingItem item, String category) {
    return GestureDetector(
      onTap: () => _showEditItemDialog(item),
      onLongPress: () {
        _showContextMenuForItem(item);
      },
      child: Card(
        elevation: 2,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: (item.imageUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            item.imageUrl ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (item.brand?.isNotEmpty ?? false)
                            ? item.brand ?? ''
                            : _getCategoryDisplayName(item.category),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: item.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    // ref
                    //     .read(wardrobeRepositoryProvider)
                    //     .toggleClothingItemFavorite(item.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitItem(Outfit outfit) {
    return GestureDetector(
      onTap: () => _showEditOutfitDialog(outfit),
      onLongPress: () {
        _showContextMenuForOutfit(outfit);
      },
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (outfit.imageUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            outfit.imageUrl ?? '',
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.checkroom,
                            size: 40,
                            color: Colors.grey,
                          ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          outfit.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.name ?? '',
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          outfit.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: outfit.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          // ref
                          //     .read(wardrobeRepositoryProvider)
                          //     .toggleOutfitFavorite(outfit.id);
                        },
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${outfit.timesWorn} раз(а)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenuForItem(ClothingItem item) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Редактировать'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: item.isFavorite ? Colors.red : null,
              ),
              const SizedBox(width: 8),
              Text(item.isFavorite
                  ? 'Убрать из избранного'
                  : 'Добавить в избранное'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Удалить', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'edit':
            _showEditItemDialog(item);
            break;
          case 'favorite':
            // ref
            //     .read(wardrobeRepositoryProvider)
            //     .toggleClothingItemFavorite(item.id);
            break;
          case 'delete':
            _confirmDeleteItem(item);
            break;
        }
      }
    });
  }

  void _showContextMenuForOutfit(Outfit outfit) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: const [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Редактировать'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                outfit.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: outfit.isFavorite ? Colors.red : null,
              ),
              const SizedBox(width: 8),
              Text(outfit.isFavorite
                  ? 'Убрать из избранного'
                  : 'Добавить в избранное'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Удалить', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'edit':
            _showEditOutfitDialog(outfit);
            break;
          case 'favorite':
            // ref
            //     .read(wardrobeRepositoryProvider)
            //     .toggleOutfitFavorite(outfit.id);
            break;
          case 'delete':
            _confirmDeleteOutfit(outfit);
            break;
        }
      }
    });
  }

  void _confirmDeleteItem(ClothingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content:
            Text('Вы уверены, что хотите удалить "${item.name}" из гардероба?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(wardrobeRepositoryProvider).deleteClothingItem(item.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Предмет удален из гардероба')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOutfit(Outfit outfit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение удаления'),
        content:
            Text('Вы уверены, что хотите удалить "${outfit.name}" из образов?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref.read(wardrobeRepositoryProvider).deleteOutfit(outfit.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Образ удален')),
              );
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  ClothingCategory _getCategoryEnum(String category) {
    switch (category) {
      case 'Верх':
        return ClothingCategory.tops;
      case 'Низ':
        return ClothingCategory.bottoms;
      case 'Обувь':
        return ClothingCategory.shoes;
      case 'Аксессуары':
        return ClothingCategory.accessories;
      case 'Верхняя одежда':
        return ClothingCategory.outerwear;
      case 'Сумки':
        return ClothingCategory.bags;
      case 'Спортивная одежда':
        return ClothingCategory.sportswear;
      case 'Платья':
        return ClothingCategory.dresses;
      default:
        return ClothingCategory.tops;
    }
  }

  String _getCategoryDisplayName(ClothingCategory category) {
    switch (category) {
      case ClothingCategory.tops:
        return 'Верх';
      case ClothingCategory.bottoms:
        return 'Низ';
      case ClothingCategory.shoes:
        return 'Обувь';
      case ClothingCategory.accessories:
        return 'Аксессуары';
      case ClothingCategory.outerwear:
        return 'Верхняя одежда';
      case ClothingCategory.bags:
        return 'Сумки';
      case ClothingCategory.sportswear:
        return 'Спортивная одежда';
      case ClothingCategory.dresses:
        return 'Платья';
      default:
        return 'Неизвестная категория';
    }
  }

  ClothingSeason _getCurrentSeason(int month) {
    if (month >= 3 && month <= 5) return ClothingSeason.spring;
    if (month >= 6 && month <= 8) return ClothingSeason.summer;
    if (month >= 9 && month <= 11) return ClothingSeason.autumn;
    return ClothingSeason.winter;
  }
}

// Providers for managing wardrobe data
final _clothingItemsProvider = FutureProvider<List<ClothingItem>>((ref) async {
  // In a real app, this would fetch from repository
  // For now, returning empty list
  return [];
});

final _outfitsProvider = FutureProvider<List<Outfit>>((ref) async {
  // In a real app, this would fetch from repository
  // For now, returning empty list
  return [];
});

// Search delegate for wardrobe items
class WardrobeSearchDelegate extends SearchDelegate {
  final Ref ref;

  WardrobeSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Введите запрос для поиска'));
    }

    // In a real app, this would search through wardrobe items
    return const Center(child: Text('Результаты поиска'));

    // Example implementation:
    // final wardrobeRepo = ref.read(wardrobeRepositoryProvider);
    // final results = wardrobeRepo.searchClothingItems(query);
    // return ListView.builder(
    //   itemCount: results.length,
    //   itemBuilder: (context, index) {
    //     final item = results[index];
    //     return ListTile(
    //       title: Text(item.name),
    //       subtitle: Text(item.description),
    //       leading: item.imageUrl.isNotEmpty
    //           ? Image.network(item.imageUrl)
    //           : const Icon(Icons.clothes),
    //     );
    //   },
    // );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Введите запрос для поиска'));
    }

    // In a real app, this would suggest search terms
    return const Center(child: Text('Предложения поиска'));
  }
}

// Dialog for adding/editing clothing items
class AddEditItemDialog extends StatefulWidget {
  final Function(ClothingItem) onSave;
  final ClothingItem clothingItem;
  final bool isEditing;

  const AddEditItemDialog({
    Key? key,
    required this.onSave,
    required this.clothingItem,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandController;
  late TextEditingController _colorController;
  late TextEditingController _materialController;
  late String _selectedCategory;
  late List<String> _selectedTags;
  late List<ClothingSeason> _selectedSeasons;
  late List<ClothingWeather> _selectedWeather;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.clothingItem.name);
    _descriptionController =
        TextEditingController(text: widget.clothingItem.description);
    _brandController = TextEditingController(text: widget.clothingItem.brand);
    _colorController = TextEditingController(text: widget.clothingItem.color);
    _materialController =
        TextEditingController(text: widget.clothingItem.material);

    _selectedCategory = widget.clothingItem.category.name;
    _selectedTags = List.from(widget.clothingItem.tags);
    _selectedSeasons = List.from(widget.clothingItem.seasons);
    _selectedWeather = List.from(widget.clothingItem.weatherConditions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.isEditing ? 'Редактировать предмет' : 'Добавить предмет'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название предмета';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Категория',
                    border: OutlineInputBorder(),
                  ),
                  items: ClothingCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category.name,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(
                    labelText: 'Бренд',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    labelText: 'Цвет',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _materialController,
                  decoration: const InputDecoration(
                    labelText: 'Материал',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMultiSelectSection(
                  'Сезоны',
                  ClothingSeason.values,
                  _selectedSeasons,
                  (season) => season.displayName,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectSection(
                  'Погодные условия',
                  ClothingWeather.values,
                  _selectedWeather,
                  (weather) => weather.displayName,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newItem = widget.clothingItem.copyWith(
                id: (widget.clothingItem.id?.isEmpty ?? true)
                    ? DateTime.now().millisecondsSinceEpoch.toString()
                    : widget.clothingItem.id ?? '',
                name: _nameController.text,
                description: _descriptionController.text,
                brand: _brandController.text,
                color: _colorController.text,
                material: _materialController.text,
                category: ClothingCategory.values.firstWhere(
                  (element) => element.name == _selectedCategory,
                ),
                seasons: _selectedSeasons,
                weatherConditions: _selectedWeather,
                addedDate: widget.clothingItem.addedDate ?? DateTime.now(),
              );

              widget.onSave(newItem);
            }
          },
          child: Text(widget.isEditing ? 'Сохранить' : 'Добавить'),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection<T>(
    String title,
    List<T> allOptions,
    List<T> selectedOptions,
    String Function(T) displayName,
  ) {
    return ExpansionTile(
      title: Text(title),
      children: allOptions.map((option) {
        return CheckboxListTile(
          title: Text(displayName(option)),
          value: selectedOptions.contains(option),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedOptions.add(option);
              } else {
                selectedOptions.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

// Dialog for adding/editing outfits
class AddEditOutfitDialog extends StatefulWidget {
  final Function(Outfit) onSave;
  final Outfit outfit;
  final bool isEditing;

  const AddEditOutfitDialog({
    Key? key,
    required this.onSave,
    required this.outfit,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<AddEditOutfitDialog> createState() => _AddEditOutfitDialogState();
}

class _AddEditOutfitDialogState extends State<AddEditOutfitDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<String> _selectedTags;
  late List<OutfitOccasion> _selectedOccasions;
  late List<OutfitWeather> _selectedWeather;
  late List<OutfitSeason> _selectedSeasons;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.outfit.name);
    _descriptionController =
        TextEditingController(text: widget.outfit.description);

    _selectedTags = List.from(widget.outfit.tags);
    _selectedOccasions = List.from(widget.outfit.occasions);
    _selectedWeather = List.from(widget.outfit.weatherConditions);
    _selectedSeasons = List.from(widget.outfit.seasons);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Редактировать образ' : 'Создать образ'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите название образа';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Описание',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectSection(
                  'Повод',
                  OutfitOccasion.values,
                  _selectedOccasions,
                  (occasion) => occasion.displayName,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectSection(
                  'Погодные условия',
                  OutfitWeather.values,
                  _selectedWeather,
                  (weather) => weather.displayName,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectSection(
                  'Сезоны',
                  OutfitSeason.values,
                  _selectedSeasons,
                  (season) => season.displayName,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newOutfit = widget.outfit.copyWith(
                id: (widget.outfit.id?.isEmpty ?? true)
                    ? DateTime.now().millisecondsSinceEpoch.toString()
                    : widget.outfit.id ?? '',
                name: _nameController.text,
                description: _descriptionController.text,
                occasions: _selectedOccasions,
                weatherConditions: _selectedWeather,
                seasons: _selectedSeasons,
                addedDate: widget.outfit.addedDate ?? DateTime.now(),
              );

              widget.onSave(newOutfit);
            }
          },
          child: Text(widget.isEditing ? 'Сохранить' : 'Создать'),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection<T>(
    String title,
    List<T> allOptions,
    List<T> selectedOptions,
    String Function(T) displayName,
  ) {
    return ExpansionTile(
      title: Text(title),
      children: allOptions.map((option) {
        return CheckboxListTile(
          title: Text(displayName(option)),
          value: selectedOptions.contains(option),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedOptions.add(option);
              } else {
                selectedOptions.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
