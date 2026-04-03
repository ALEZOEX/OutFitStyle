import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/wardrobe_request_entities.dart';
import '../../../ui/widgets/max_width_container.dart';
import '../presentation/providers/wardrobe_provider.dart';
import '../../../ui/widgets/wardrobe_item_card.dart';
import '../../../theme/app_theme.dart';

/// Экран гардероба — личные вещи пользователя
class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends ConsumerState<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Optimized: 800 → 400
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    final wardrobeState = ref.watch(wardrobeProvider);
    final categories = ref.watch(wardrobeCategoriesProvider);

    return Scaffold(
      body: ResponsiveMaxWidthContainer(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, wardrobeState)),
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCategoryFilters(context, categories),
              ),
            _buildWardrobeGrid(context, wardrobeState),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 78),
        child: FloatingActionButton.extended(
          heroTag: 'addBtn',
          onPressed: () => _showAddItemBottomSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Добавить'),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WardrobeState state) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.totalCount} вещей',
                  style: AppTypography.bodyMedium(context),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(wardrobeProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Обновить',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsRow(context, state),
          ],
        ),
      ),
    );
  }

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
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.favorite,
            label: 'Избранное',
            value: state.favoritesCount.toString(),
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.category,
            label: 'Категории',
            value: state.categoryCounts.length.toString(),
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: color.withValues(alpha: isDark ? 0.3 : 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
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

  Widget _buildCategoryFilters(
    BuildContext context,
    Map<String, int> categories,
  ) {
    final theme = Theme.of(context);

    final allCategories = {'all': categories.values.fold(0, (a, b) => a + b)}
      ..addAll(categories);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: 56,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: allCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final entry = allCategories.entries.elementAt(index);
            final category = entry.key == 'all'
                ? 'Все'
                : _getCategoryName(entry.key);

            return FilterChip(
              selected: _selectedCategory == entry.key,
              onSelected: (_) {
                setState(() {
                  _selectedCategory = _selectedCategory == entry.key
                      ? null
                      : entry.key;
                });
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getCategoryEmoji(entry.key)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(category),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedCategory == entry.key
                          ? theme.colorScheme.onPrimary.withValues(alpha: 0.3)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      '${entry.value}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMd,
                side: BorderSide(
                  color: _selectedCategory == entry.key
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWardrobeGrid(BuildContext context, WardrobeState state) {
    final theme = Theme.of(context);

    if (state.status == WardrobeLoadStatus.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == WardrobeLoadStatus.error) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isAuthError ? Icons.lock_outline : Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  state.error ?? 'Ошибка загрузки',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.isAuthError)
                  ElevatedButton.icon(
                    onPressed: () => context.go('/auth'),
                    icon: const Icon(Icons.login),
                    label: const Text('Войти снова'),
                  )
                else
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(wardrobeProvider.notifier).refresh(),
                    child: const Text('Повторить'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    var items = state.items;
    if (_selectedCategory != null && _selectedCategory != 'all') {
      items = items
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    if (items.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(context));
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: WardrobeItemCard(
              item: item,
              onTap: () => context.push('/wardrobe/item/${item.id}'),
              onFavorite: () =>
                  ref.read(wardrobeProvider.notifier).toggleFavorite(item.id!),
            ),
          );
        }, childCount: items.length),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppGradients.cardDark
                    : AppGradients.cardLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Гардероб пуст', style: AppTypography.headlineSmall(context)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Добавьте первую вещь в свой гардероб',
              style: AppTypography.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => _showAddItemBottomSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Добавить вещь'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (context) => _AddItemSheet(
        onItemAdded: () {
          ref.read(wardrobeProvider.notifier).refresh();
        },
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

  String _getCategoryEmoji(String category) {
    return switch (category.toLowerCase()) {
      'all' => '📋',
      'top' => '👕',
      'bottom' => '👖',
      'shoes' => '👟',
      'headwear' => '🧢',
      'accessory' => '🧣',
      'outerwear' => '🧥',
      _ => '👔',
    };
  }
}

/// Bottom sheet для добавления вещи — без изменений бизнес-логики
class _AddItemSheet extends ConsumerStatefulWidget {
  final VoidCallback? onItemAdded;

  const _AddItemSheet({this.onItemAdded});

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '👕';
  String _selectedCategory = 'top';
  bool _isSubmitting = false;
  String? _errorMessage;

  final _emojiCategories = {
    'top': ['👕', '👚', '👔', '👗', '👘', '🥻', '🥼', '🧥', '🦺', '👙', '🩱'],
    'bottom': ['👖', '🩳', '👗', '👘', '🥻', '👙', '🩱', '🩲'],
    'shoes': ['👟', '👞', '👠', '👡', '👢', '🥿', '🥾', '🩴'],
    'outerwear': ['🧥', '🦺', '🥼', '👘', '🥻'],
    'headwear': ['🧢', '👒', '🎩', '🎓', '🧕', '⛑️', '👑'],
    'accessory': [
      '👜',
      '👛',
      '👝',
      '👓',
      '🕶️',
      '⌚',
      '💍',
      '🎒',
      '🎀',
      '🧣',
      '🧤',
      '🧦',
    ],
  };

  final _categories = [
    {'value': 'top', 'label': 'Верх', 'icon': Icons.checkroom},
    {'value': 'bottom', 'label': 'Низ', 'icon': Icons.content_paste},
    {'value': 'shoes', 'label': 'Обувь', 'icon': Icons.sports_soccer},
    {'value': 'outerwear', 'label': 'Верхняя одежда', 'icon': Icons.ac_unit},
    {'value': 'headwear', 'label': 'Головной убор', 'icon': Icons.face},
    {'value': 'accessory', 'label': 'Аксессуар', 'icon': Icons.watch},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Введите название вещи';
      });
      return;
    }

    if (name.length < 2) {
      setState(() {
        _errorMessage = 'Название должно быть не менее 2 символов';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final request = WardrobeItemCreateRequest(
        name: '$_selectedEmoji $name',
        category: _selectedCategory,
        subcategory: _getSubcategory(_selectedCategory),
        style: 'casual',
        iconEmoji: _selectedEmoji,
        isFavorite: false,
        isArchived: false,
        rainOk: false,
        snowOk: false,
        windOk: false,
        userId: 'current_user',
        clothingItemId: '',
      );

      await ref.read(wardrobeProvider.notifier).addItem(request);

      widget.onItemAdded?.call();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppSpacing.md),
                Text('Вещь "${request.name}" добавлена'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = _getErrorMessage(e);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(_errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        );
      }
    }
  }

  String _getSubcategory(String category) {
    return switch (category) {
      'top' => 'tshirt',
      'bottom' => 'jeans',
      'shoes' => 'sneakers',
      'outerwear' => 'jacket',
      'headwear' => 'cap',
      'accessory' => 'belt',
      _ => 'other',
    };
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('Требуется авторизация')) {
      return 'Требуется авторизация';
    }
    if (errorStr.contains('Нет соединения') ||
        errorStr.contains('connection')) {
      return 'Нет соединения с интернетом';
    }
    if (errorStr.contains('Ошибка сервера')) {
      return 'Ошибка сервера. Попробуйте позже';
    }
    return 'Ошибка добавления: ${error.toString().replaceAll("WardrobeException: ", "")}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('Добавить вещь', style: AppTypography.headlineSmall(context)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Выберите эмодзи и введите название',
            style: AppTypography.bodyMedium(context),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Выбор категории
          Text('Категория', style: AppTypography.labelLarge(context)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat['value'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat['icon'] as IconData, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                    Text(cat['label'] as String),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategory = cat['value'] as String;
                      final emojis = _emojiCategories[_selectedCategory] ?? [];
                      _selectedEmoji = emojis.firstOrNull ?? '😊';
                    });
                  }
                },
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Выбор эмодзи
          Text('Выберите эмодзи', style: AppTypography.labelLarge(context)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: (_emojiCategories[_selectedCategory] ?? []).map((emoji) {
              final isSelected = _selectedEmoji == emoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Название
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Название вещи',
              hintText: 'Например: любимая футболка',
              prefixText: '$_selectedEmoji  ',
              errorText:
                  _errorMessage != null && _nameController.text.trim().isEmpty
                  ? _errorMessage
                  : null,
            ),
            autofocus: true,
            enabled: !_isSubmitting,
            onSubmitted: (_) => _saveItem(),
          ),
          if (_errorMessage != null && _nameController.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),

          // Кнопка сохранения
          SizedBox(
            width: double.infinity,
            height: AppSpacing.inputHeight,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _saveItem,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSubmitting ? 'Добавление...' : 'Добавить в гардероб',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
