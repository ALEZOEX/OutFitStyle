import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/wardrobe_item.dart';
import '../../../domain/entities/wardrobe_request_entities.dart';
import '../../../ui/widgets/max_width_container.dart';
import '../presentation/providers/wardrobe_provider.dart';
import '../../../ui/widgets/wardrobe_item_card.dart';

/// Экран гардероба - личные вещи пользователя
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
    final wardrobeState = ref.watch(wardrobeProvider);
    final categories = ref.watch(wardrobeCategoriesProvider);

    return Scaffold(
      body: ResponsiveMaxWidthContainer(
        child: CustomScrollView(
          slivers: [
            // Заголовок со статистикой
            SliverToBoxAdapter(child: _buildHeader(context, wardrobeState)),
            // Фильтры по категориям
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCategoryFilters(context, categories),
              ),
            // Список элементов
            _buildWardrobeGrid(context, wardrobeState),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Основная кнопка "Добавить"
          FloatingActionButton.extended(
            heroTag: 'addBtn',
            onPressed: () => _showAddItemBottomSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Добавить'),
          ),
        ],
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
                      '${state.totalCount} вещей',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed:
                      () => ref.read(wardrobeProvider.notifier).refresh(),
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
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
  Widget _buildCategoryFilters(
    BuildContext context,
    Map<String, int> categories,
  ) {
    final theme = Theme.of(context);

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
            final category =
                entry.key == 'all' ? 'Все' : _getCategoryName(entry.key);

            return FilterChip(
              selected: _selectedCategory == entry.key,
              onSelected: (_) {
                setState(() {
                  _selectedCategory =
                      _selectedCategory == entry.key ? null : entry.key;
                });
              },
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getCategoryEmoji(entry.key)),
                  const SizedBox(width: 4),
                  Text(category),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _selectedCategory == entry.key
                              ? theme.colorScheme.onPrimary.withOpacity(0.3)
                              : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
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
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      _selectedCategory == entry.key
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                ),
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

    if (state.status == WardrobeLoadStatus.loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
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

    // Фильтрация по категории
    var items = state.items;
    if (_selectedCategory != null && _selectedCategory != 'all') {
      items =
          items.where((item) => item.category == _selectedCategory).toList();
    }

    if (items.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(context));
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
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: WardrobeItemCard(
              item: item,
              onTap: () => context.push('/wardrobe/item/${item.id}'),
              onFavorite:
                  () => ref
                      .read(wardrobeProvider.notifier)
                      .toggleFavorite(item.id!),
            ),
          );
        }, childCount: items.length),
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
              onPressed: () => _showAddItemBottomSheet(context),
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

  /// Bottom sheet для добавления элемента
  void _showAddItemBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => _AddItemSheet(
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

/// Bottom sheet для добавления вещи
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
    // Валидация
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
      // Создаём запрос на добавление вещи в формате API
      final request = WardrobeItemCreateRequest(
        name: '${_selectedEmoji} $name',
        category: _selectedCategory,
        subcategory: _getSubcategory(_selectedCategory),
        style: 'casual',
        iconEmoji: _selectedEmoji,
        isFavorite: false,
        isArchived: false,
        rainOk: false,
        snowOk: false,
        windOk: false,
        userId: 'current_user', // В реальном приложении брать из auth
        clothingItemId: '', // Пусто для новых вещей
      );

      // Добавляем через провайдер с интеграцией API
      await ref.read(wardrobeProvider.notifier).addItem(request);

      widget.onItemAdded?.call();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Вещь "${request.name}" добавлена'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
                const SizedBox(width: 12),
                Expanded(child: Text(_errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Получить подкатегорию по категории
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

  /// Получить понятное сообщение об ошибке
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
        left: 24,
        right: 24,
        top: 24,
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
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Заголовок
          Text(
            'Добавить вещь',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите эмодзи и введите название',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Выбор категории
          Text(
            'Категория',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 18),
                        const SizedBox(width: 4),
                        Text(cat['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat['value'] as String;
                          _selectedEmoji =
                              _emojiCategories[_selectedCategory]!.first;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    checkmarkColor: theme.colorScheme.onPrimaryContainer,
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          // Выбор эмодзи
          Text(
            'Выберите эмодзи',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _emojiCategories[_selectedCategory]!.map((emoji) {
                  final isSelected = _selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          // Название
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Название вещи',
              hintText: 'Например: любимая футболка',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          // Сообщение об ошибке
          if (_errorMessage != null && _nameController.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 24),
          // Кнопка сохранения с индикатором загрузки
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _saveItem,
              icon:
                  _isSubmitting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.save),
              label: Text(
                _isSubmitting ? 'Добавление...' : 'Добавить в гардероб',
              ),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
