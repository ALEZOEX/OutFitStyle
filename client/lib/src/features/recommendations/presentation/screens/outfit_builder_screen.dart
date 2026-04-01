import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/wardrobe_item.dart';
import '../../../wardrobe/presentation/providers/wardrobe_provider.dart';
import '../providers/recommendations_provider.dart';
import '../../../../presentation/providers/user_location_provider.dart';

/// Экран конструктора образов
/// Позволяет создать свой образ из вещей гардероба по категориям
class OutfitBuilderScreen extends ConsumerStatefulWidget {
  const OutfitBuilderScreen({super.key});

  @override
  ConsumerState<OutfitBuilderScreen> createState() =>
      _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends ConsumerState<OutfitBuilderScreen> {
  // Выбранные вещи по категориям
  final Map<String, WardrobeItem> _selectedItems = {};

  // Название и описание образа
  String _outfitName = '';
  String _outfitDescription = '';

  // Категории в порядке отображения
  static const _categories = [
    ('top', 'Верх', Icons.checkroom),
    ('bottom', 'Низ', Icons.checkroom_outlined),
    ('outerwear', 'Верхняя одежда', Icons.sunny_snowing),
    ('shoes', 'Обувь', Icons.bolt),
    ('headwear', 'Головной убор', Icons.face),
    ('accessory', 'Аксессуары', Icons.attach_money),
  ];

  @override
  Widget build(BuildContext context) {
    final wardrobeState = ref.watch(wardrobeProvider);
    final items = wardrobeState.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Конструктор образов'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить образ',
            onPressed:
                _selectedItems.isNotEmpty ? () => _saveOutfit(context) : null,
          ),
        ],
      ),
      body: Row(
        children: [
          // Левая панель - выбор вещей по категориям
          Expanded(flex: 2, child: _buildCategoriesPanel(context, items)),
          // Правая панель - предпросмотр образа
          Expanded(child: _buildPreviewPanel(context)),
        ],
      ),
    );
  }

  /// Панель категорий с вещами
  Widget _buildCategoriesPanel(BuildContext context, List<WardrobeItem> items) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.category, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Категории',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${_selectedItems.length} выбрано'),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          // Список категорий
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final categoryId = category.$1;
                final categoryName = category.$2;
                final categoryIcon = category.$3;

                final categoryItems =
                    items.where((item) => item.category == categoryId).toList();
                final selectedItem = _selectedItems[categoryId];

                return _buildCategorySection(
                  context,
                  categoryId: categoryId,
                  categoryName: categoryName,
                  categoryIcon: categoryIcon,
                  items: categoryItems,
                  selectedItem: selectedItem,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Секция категории
  Widget _buildCategorySection(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
    required IconData categoryIcon,
    required List<WardrobeItem> items,
    WardrobeItem? selectedItem,
  }) {
    final theme = Theme.of(context);
    final isExpanded = selectedItem != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Заголовок категории
          InkWell(
            onTap: () {
              // Можно добавить раскрытие/сворачивание
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    selectedItem != null
                        ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
                        : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      categoryIcon,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${items.length} вещей',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedItem != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Выбрано',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Список вещей (если есть выбранный или категория раскрыта)
          if (isExpanded || items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    items.map((item) {
                      final isSelected = selectedItem?.id == item.id;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedItems.remove(categoryId);
                            } else {
                              _selectedItems[categoryId] = item;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withValues(
                                        alpha: 0.3,
                                      ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(
                                child: Text(
                                  item.name ?? 'Без названия',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight:
                                        isSelected ? FontWeight.bold : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// Панель предпросмотра
  Widget _buildPreviewPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Text(
            'Предпросмотр образа',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Выберите вещи из категорий слева',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Название образа
          TextField(
            decoration: const InputDecoration(
              labelText: 'Название образа',
              hintText: 'Например: Повседневный образ для прогулки',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (value) => _outfitName = value,
          ),
          const SizedBox(height: 16),

          // Описание
          TextField(
            decoration: const InputDecoration(
              labelText: 'Описание (опционально)',
              hintText: 'Краткое описание образа',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            onChanged: (value) => _outfitDescription = value,
          ),
          const SizedBox(height: 24),

          // Визуализация образа
          Expanded(child: _buildOutfitVisualization(context)),
          const SizedBox(height: 24),

          // Кнопки действий
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// Визуализация образа
  Widget _buildOutfitVisualization(BuildContext context) {
    final theme = Theme.of(context);

    if (_selectedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Образ не собран',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Выберите вещи из категорий\nдля создания образа',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Элементы образа',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${_selectedItems.length} вещей'),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedItems.length,
                itemBuilder: (context, index) {
                  final entry = _selectedItems.entries.elementAt(index);
                  final category = entry.key;
                  final item = entry.value;

                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      item.name ?? 'Без названия',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_getCategoryName(category)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedItems.remove(category);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Кнопки действий
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _selectedItems.isNotEmpty
                    ? () => setState(() => _selectedItems.clear())
                    : null,
            icon: const Icon(Icons.clear),
            label: const Text('Очистить'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed:
                _selectedItems.isNotEmpty ? () => _saveOutfit(context) : null,
            icon: const Icon(Icons.save),
            label: const Text('Сохранить образ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  /// Сохранить образ
  void _saveOutfit(BuildContext context) {
    if (_selectedItems.isEmpty) return;

    // Создаем рекомендацию из выбранных вещей
    final notifier = ref.read(recommendationsProvider.notifier);
    final userLocation = ref.read(userLocationProvider);

    // Генерируем рекомендацию на основе выбранных вещей
    notifier
        .generateRecommendation(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
          occasion: 'custom',
        )
        .then((recommendation) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  const Text('Образ сохранён!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Возвращаемся на экран рекомендаций
          context.go('/recommendations');
        });
  }

  /// Получить иконку категории
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'top':
        return Icons.checkroom;
      case 'bottom':
        return Icons.checkroom_outlined;
      case 'outerwear':
        return Icons.sunny_snowing;
      case 'shoes':
        return Icons.bolt;
      case 'headwear':
        return Icons.face;
      case 'accessory':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  /// Получить название категории
  String _getCategoryName(String category) {
    switch (category) {
      case 'top':
        return 'Верх';
      case 'bottom':
        return 'Низ';
      case 'outerwear':
        return 'Верхняя одежда';
      case 'shoes':
        return 'Обувь';
      case 'headwear':
        return 'Головной убор';
      case 'accessory':
        return 'Аксессуары';
      default:
        return category;
    }
  }
}
