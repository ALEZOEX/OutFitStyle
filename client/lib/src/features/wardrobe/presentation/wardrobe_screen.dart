import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/wardrobe_provider.dart';
import '../../../ui/widgets/wardrobe_item_card.dart';

/// Экран гардероба
class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wardrobeState = ref.watch(wardrobeProvider);
    final categories = ref.watch(wardrobeCategoriesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Заголовок со статистикой
          SliverToBoxAdapter(
            child: _buildHeader(context, wardrobeState),
          ),
          // Фильтры по категориям
          SliverToBoxAdapter(
            child: _buildCategoryFilters(context, categories),
          ),
          // Список элементов
          _buildWardrobeGrid(context, wardrobeState),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  /// Заголовок со статистикой
  Widget _buildHeader(BuildContext context, WardrobeState state) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Гардероб',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.totalCount} вещей в гардеробе',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Кнопка обновления
                IconButton(
                  onPressed: () => ref.read(wardrobeProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Статистика
            _buildStatsRow(context, state),
          ],
        ),
      ),
    );
  }

  /// Строка статистики
  Widget _buildStatsRow(BuildContext context, WardrobeState state) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.checkroom,
            label: 'Всего',
            value: state.totalCount.toString(),
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.favorite,
            label: 'Избранное',
            value: state.favoritesCount.toString(),
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.category,
            label: 'Категории',
            value: state.categoryCounts.length.toString(),
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  /// Карточка статистики
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Фильтры по категориям
  Widget _buildCategoryFilters(BuildContext context, Map<String, int> categories) {
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(wardrobeProvider).selectedCategory;
    final notifier = ref.read(wardrobeProvider.notifier);

    // Добавляем категорию "Все"
    final allCategories = {'all': categories.values.fold(0, (a, b) => a + b)}
      ..addAll(categories);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: allCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final entry = allCategories.entries.elementAt(index);
            final category = entry.key == 'all' ? 'Все' : _getCategoryName(entry.key);

            return CategoryFilterChip(
              category: entry.key,
              count: entry.value,
              isSelected: selectedCategory == entry.key,
              onTap: () => notifier.selectCategory(
                entry.key == selectedCategory ? null : entry.key,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Сетка элементов гардероба
  Widget _buildWardrobeGrid(BuildContext context, WardrobeState state) {
    final theme = Theme.of(context);
    final items = state.filteredItems;

    if (state.status == WardrobeLoadStatus.loading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == WardrobeLoadStatus.error) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                state.error ?? 'Ошибка загрузки',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(wardrobeProvider.notifier).refresh(),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(context),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: WardrobeItemCard(
                item: item,
                onTap: () => _showItemDetails(context, item),
                onFavorite: () => ref.read(wardrobeProvider.notifier).toggleFavorite(item.id!),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.5),
                    theme.colorScheme.secondaryContainer.withOpacity(0.5),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Гардероб пуст',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первую вещь в свой гардероб',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Добавить вещь'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог добавления элемента
  void _showAddItemDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Добавить вещь',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            // Здесь будет форма добавления
            _buildQuickAddOptions(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Опции быстрого добавления
  Widget _buildQuickAddOptions(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      {'icon': Icons.photo_camera, 'label': 'Фото', 'color': Colors.blue},
      {'icon': Icons.upload_file, 'label': 'Загрузить', 'color': Colors.green},
      {'icon': Icons.style, 'label': 'Из каталога', 'color': Colors.purple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((option) {
        return InkWell(
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Функция "${option['label']}" в разработке'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: (option['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 32,
                  color: option['color'] as Color,
                ),
                const SizedBox(height: 8),
                Text(
                  option['label'] as String,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Детали элемента
  void _showItemDetails(BuildContext context, dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              item.name ?? 'Без названия',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Детали элемента
            _buildDetailRow(context, 'Категория', _getCategoryName(item.category ?? '')),
            if (item.brand != null) _buildDetailRow(context, 'Бренд', item.brand),
            if (item.color != null) _buildDetailRow(context, 'Цвет', item.color),
            if (item.size != null) _buildDetailRow(context, 'Размер', item.size),
            if (item.style != null) _buildDetailRow(context, 'Стиль', item.style),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(wardrobeProvider.notifier).toggleFavorite(item.id!);
                      Navigator.pop(context);
                    },
                    icon: Icon(item.isFavorite == true ? Icons.favorite : Icons.favorite_border),
                    label: const Text('Избранное'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Изменить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    return switch (category.toLowerCase()) {
      'all' => 'Все',
      'top' => 'Верх',
      'bottom' => 'Низ',
      'shoes' => 'Обувь',
      'headwear' => 'Головной убор',
      'accessory' => 'Аксессуар',
      'outerwear' => 'Верхняя одежда',
      _ => category,
    };
  }
}
