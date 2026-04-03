import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';
import 'package:outfitstyle_client/src/ui/containers/glass_components.dart';
import 'package:outfitstyle_client/src/domain/entities/wardrobe_item.dart';
import 'package:outfitstyle_client/src/domain/entities/saved_outfit.dart';
import 'package:outfitstyle_client/src/features/wardrobe/presentation/providers/wardrobe_provider.dart';
import 'package:outfitstyle_client/src/features/builder/presentation/providers/outfit_provider.dart';

/// Экран конструктора образов
///
/// Загружает реальные вещи из гардероба через WardrobeProvider
/// и сохраняет образы через Outfit API.
class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  int _selectedCategoryIndex = 0;
  final Map<String, List<WardrobeItem>> _selectedItems = {};
  bool _isSaving = false;

  final List<_Category> _categories = [
    _Category(
      id: WardrobeCategories.top,
      label: 'Верх',
      icon: Icons.checkroom,
    ),
    _Category(
      id: WardrobeCategories.bottom,
      label: 'Низ',
      icon: Icons.checkroom_outlined,
    ),
    _Category(
      id: WardrobeCategories.shoes,
      label: 'Обувь',
      icon: Icons.directions_walk,
    ),
    _Category(
      id: WardrobeCategories.accessories,
      label: 'Аксессуары',
      icon: Icons.backpack,
    ),
    _Category(
      id: WardrobeCategories.outerwear,
      label: 'Верхняя одежда',
      icon: Icons.umbrella_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Загружаем гардероб
    final wardrobeState = ref.watch(wardrobeProvider);
    final wardrobeItems = wardrobeState.items;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(context),

            // Индикатор загрузки гардероба
            if (wardrobeState.status == WardrobeLoadStatus.loading)
              const LinearProgressIndicator()
            else if (wardrobeState.status == WardrobeLoadStatus.error)
              _buildErrorBanner(context, wardrobeState.error ?? 'Ошибка загрузки'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview образа
                    _buildPreview(context, isDark),
                    const SizedBox(height: AppSpacing.lg),

                    // Категории
                    Text(
                      'Категории',
                      style: AppTypography.labelLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildCategories(context),
                    const SizedBox(height: AppSpacing.lg),

                    // Список вещей
                    Text(
                      _categories[_selectedCategoryIndex].label,
                      style: AppTypography.labelLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildItemsList(context, isDark, wardrobeItems),
                    const SizedBox(height: AppSpacing.xl),

                    // Кнопки действий
                    _buildActionButtons(context, wardrobeItems),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onErrorContainer,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Конструктор образа',
              style: AppTypography.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GlassButton(
            label: 'Сохранить',
            icon: Icons.save,
            onPressed: _saveOutfit,
            width: 140,
            isLoading: _isSaving,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, bool isDark) {
    final selectedCount = _selectedItems.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    return GlassCard(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Превью образа',
                style: AppTypography.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: AppRadius.radiusPill,
                ),
                child: Text(
                  '$selectedCount предметов',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: selectedCount == 0
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.checkroom_outlined,
                          size: 48,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Выберите вещи для создания образа',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedItems.length,
                    itemBuilder: (context, index) {
                      final category = _selectedItems.keys.elementAt(index);
                      final items = _selectedItems[category]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              WardrobeCategories.getNameRu(category),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.sm,
                                  top: 2,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      item.emojiOrPlaceholder,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        item.name ?? 'Без названия',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GlassChip(
            label: category.label,
            icon: category.icon,
            isSelected: _selectedCategoryIndex == index,
            onTap: () =>
                setState(() => _selectedCategoryIndex = index),
          );
        },
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    bool isDark,
    List<WardrobeItem> wardrobeItems,
  ) {
    final categoryId = _categories[_selectedCategoryIndex].id;
    final itemsInCategory = wardrobeItems
        .where(
          (item) =>
              item.category?.toLowerCase() == categoryId.toLowerCase() &&
              !(item.isArchived == true),
        )
        .toList();
    final selectedItems = _selectedItems[categoryId] ?? [];

    if (itemsInCategory.isEmpty) {
      final hasAnyItems = wardrobeItems.isNotEmpty;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(
                _categories[_selectedCategoryIndex].icon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                hasAnyItems
                    ? 'Нет вещей в категории'
                    : 'Гардероб пуст',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              if (!hasAnyItems)
                GlassButton(
                  label: 'Добавить вещи',
                  icon: Icons.add_shopping_cart,
                  onPressed: () {
                    Navigator.pop(context);
                    // Переход на таб гардероба (индекс 1)
                    context.go('/home', extra: 1);
                  },
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemsInCategory.length,
      itemBuilder: (context, index) {
        final item = itemsInCategory[index];
        final isSelected = selectedItems.any((i) => i.id == item.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            onTap: () => _toggleItem(categoryId, item),
            child: Row(
              children: [
                // Фото или emoji
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: AppRadius.radiusMd,
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              item.emojiOrPlaceholder,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      : Text(
                          item.emojiOrPlaceholder,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? 'Без названия',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.color != null)
                        Text(
                          item.color!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    List<WardrobeItem> wardrobeItems,
  ) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            label: 'Случайный подбор',
            icon: Icons.casino,
            onPressed: () => _randomSelect(wardrobeItems),
            isPrimary: false,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: GlassButton(
            label: 'Очистить',
            icon: Icons.clear_all,
            onPressed: _clearSelection,
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  void _toggleItem(String categoryId, WardrobeItem item) {
    setState(() {
      final items = _selectedItems[categoryId] ?? [];
      final exists = items.any((i) => i.id == item.id);
      if (exists) {
        items.removeWhere((i) => i.id == item.id);
      } else {
        items.add(item);
      }
      _selectedItems[categoryId] = items;
    });
  }

  void _randomSelect(List<WardrobeItem> wardrobeItems) {
    setState(() {
      _selectedItems.clear();
      final rng = DateTime.now().millisecondsSinceEpoch;
      for (final category in _categories) {
        final itemsInCategory = wardrobeItems
            .where(
              (item) =>
                  item.category?.toLowerCase() == category.id.toLowerCase() &&
                  !(item.isArchived == true),
            )
            .toList();
        if (itemsInCategory.isNotEmpty && rng % 2 == 0) {
          _selectedItems[category.id] = [
            itemsInCategory[rng % itemsInCategory.length],
          ];
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
  }

  Future<void> _saveOutfit() async {
    final selectedCount = _selectedItems.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    if (selectedCount == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите хотя бы одну вещь')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Формируем список вещей для отправки на сервер
      final itemsJson = <Map<String, dynamic>>[];
      for (final entry in _selectedItems.entries) {
        for (final item in entry.value) {
          itemsJson.add({
            'category': entry.key,
            'item_id': item.id,
            'name': item.name,
            'image_url': item.imageUrl,
          });
        }
      }

      // Генерируем имя образа
      final outfitName = _generateOutfitName();

      final request = SavedOutfitCreateRequest(
        name: outfitName,
        items: itemsJson,
        description: 'Создано в конструкторе',
      );

      await ref.read(outfitProvider.notifier).createOutfit(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Образ сохранён!'),
            duration: Duration(seconds: 3),
          ),
        );
        // Очищаем выбор после сохранения
        _clearSelection();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _generateOutfitName() {
    final count = _selectedItems.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    final now = DateTime.now();
    return 'Образ ${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')} ($count предметов)';
  }
}

class _Category {
  final String id;
  final String label;
  final IconData icon;

  const _Category({
    required this.id,
    required this.label,
    required this.icon,
  });
}
