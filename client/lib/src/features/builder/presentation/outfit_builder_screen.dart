import 'package:flutter/material.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';
import 'package:outfitstyle_client/src/ui/containers/glass_components.dart';

/// Экран конструктора образов
class OutfitBuilderScreen extends StatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  State<OutfitBuilderScreen> createState() => _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends State<OutfitBuilderScreen> {
  int _selectedCategory = 0;
  final Map<String, List<String>> _selectedItems = {};
  bool _isSaving = false;

  final List<_Category> _categories = [
    _Category(id: 'top', label: 'Верх', icon: Icons.checkroom),
    _Category(id: 'bottom', label: 'Низ', icon: Icons.outbond),
    _Category(id: 'shoes', label: 'Обувь', icon: Icons.directions_walk),
    _Category(id: 'accessories', label: 'Аксессуары', icon: Icons.backpack),
    _Category(id: 'outerwear', label: 'Верхняя одежда', icon: Icons.umbrella_outlined),
  ];

  final Map<String, List<String>> _wardrobeItems = {
    'top': ['Футболка белая', 'Рубашка голубая', 'Свитер серый', 'Поло синее'],
    'bottom': ['Джинсы синие', 'Брюки чёрные', 'Шорты бежевые', 'Чиносы хаки'],
    'shoes': ['Кроссовки белые', 'Ботинки коричневые', 'Лоферы чёрные', 'Кеды красные'],
    'accessories': ['Ремень кожаный', 'Часы серебристые', 'Солнечные очки', 'Шарф синий'],
    'outerwear': ['Куртка демисезонная', 'Пальто чёрное', 'Ветровка синяя', 'Пуховик серый'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            _buildAppBar(context),
            
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
                      _categories[_selectedCategory].label,
                      style: AppTypography.labelLarge(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildItemsList(context, isDark),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Кнопки действий
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    final selectedCount = _selectedItems.values.fold<int>(0, (sum, list) => sum + list.length);
    
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
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
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Выберите вещи для создания образа',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedCount,
                    itemBuilder: (context, index) {
                      final category = _selectedItems.keys.elementAt(index ~/ 1);
                      final items = _selectedItems[category] ?? [];
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                items[index % items.length],
                                style: Theme.of(context).textTheme.bodyMedium,
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
            isSelected: _selectedCategory == index,
            onTap: () => setState(() => _selectedCategory = index),
          );
        },
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, bool isDark) {
    final categoryId = _categories[_selectedCategory].id;
    final items = _wardrobeItems[categoryId] ?? [];
    final selectedItems = _selectedItems[categoryId] ?? [];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItems.contains(item);
        
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    _getCategoryIcon(categoryId),
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
            label: 'Случайный подбор',
            icon: Icons.casino,
            onPressed: _randomSelect,
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

  void _toggleItem(String categoryId, String item) {
    setState(() {
      final items = _selectedItems[categoryId] ?? [];
      if (items.contains(item)) {
        items.remove(item);
      } else {
        items.add(item);
      }
      _selectedItems[categoryId] = items;
    });
  }

  void _randomSelect() {
    setState(() {
      _selectedItems.clear();
      for (final category in _wardrobeItems.keys) {
        final items = _wardrobeItems[category]!;
        if (items.isNotEmpty && DateTime.now().millisecondsSinceEpoch % 2 == 0) {
          _selectedItems[category] = [items[DateTime.now().millisecondsSinceEpoch % items.length]];
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
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Образ сохранён!')),
      );
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => _categories.first,
    );
    return category.icon;
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
