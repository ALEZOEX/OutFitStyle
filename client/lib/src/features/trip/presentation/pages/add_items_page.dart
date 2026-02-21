import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../wardrobe/presentation/providers/wardrobe_provider.dart';
import '../providers/trip_providers.dart';

/// Страница выбора вещей из гардероба для добавления в поездку
class AddItemsToTripPage extends ConsumerStatefulWidget {
  final String tripId;

  const AddItemsToTripPage({super.key, required this.tripId});

  @override
  ConsumerState<AddItemsToTripPage> createState() => _AddItemsToTripPageState();
}

class _AddItemsToTripPageState extends ConsumerState<AddItemsToTripPage> {
  final Set<String> _selectedItemIds = {};
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final wardrobeState = ref.watch(wardrobeProvider);
    final items = wardrobeState.items;
    final tripState = ref.watch(tripDetailProvider(widget.tripId));
    final trip = tripState.trip;

    // Фильтрация по категории
    final filteredItems = _selectedCategory == null || _selectedCategory == 'all'
        ? items
        : items.where((item) => item.category == _selectedCategory).toList();

    // Получаем уже добавленные вещи
    final addedItemIds = trip?.packingList.map((i) => i.wardrobeItemId).toSet() ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Добавить вещи'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedItemIds.isNotEmpty)
            TextButton(
              onPressed: () => _addSelectedItems(),
              child: Text(
                'Добавить (${_selectedItemIds.length})',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Категории
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CategoryChip(
                  label: 'Все',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Верх',
                  isSelected: _selectedCategory == 'top',
                  onTap: () => setState(() => _selectedCategory = 'top'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Низ',
                  isSelected: _selectedCategory == 'bottom',
                  onTap: () => setState(() => _selectedCategory = 'bottom'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Обувь',
                  isSelected: _selectedCategory == 'shoes',
                  onTap: () => setState(() => _selectedCategory = 'shoes'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Аксессуары',
                  isSelected: _selectedCategory == 'accessories',
                  onTap: () => setState(() => _selectedCategory = 'accessories'),
                ),
              ],
            ),
          ),

          // Список вещей
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text('Нет вещей в гардеробе'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final itemId = item.id ?? '';
                      final isAdded = addedItemIds.contains(itemId);
                      final isSelected = _selectedItemIds.contains(itemId);

                      return _WardrobeItemCard(
                        item: item,
                        isAdded: isAdded,
                        isSelected: isSelected,
                        onToggle: () {
                          setState(() {
                            if (isSelected) {
                              _selectedItemIds.remove(itemId);
                            } else {
                              _selectedItemIds.add(itemId);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSelectedItems() async {
    final notifier = ref.read(tripDetailProvider(widget.tripId).notifier);

    try {
      for (final itemId in _selectedItemIds) {
        await notifier.addPackingItem(itemId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Добавлено вещей: ${_selectedItemIds.length}'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _WardrobeItemCard extends StatelessWidget {
  final dynamic item;
  final bool isAdded;
  final bool isSelected;
  final VoidCallback onToggle;

  const _WardrobeItemCard({
    required this.item,
    required this.isAdded,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAdded ? null : onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdded
                ? Colors.grey[300]!
                : isSelected
                    ? Colors.blue[600]!
                    : Colors.grey[200]!,
            width: isAdded ? 1 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: item.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 40),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.checkroom, size: 40),
                          ),
                  ),
                  // Индикатор добавления
                  if (isAdded)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  // Индикатор выбора
                  if (isSelected && !isAdded)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Информация
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? 'Без названия',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.category != null)
                        Text(
                          item.category!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      const Spacer(),
                      if (item.minTemp != null)
                        Text(
                          '${item.minTemp}°...${item.maxTemp}°',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
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
}
