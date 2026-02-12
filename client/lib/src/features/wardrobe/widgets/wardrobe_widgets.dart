import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outfitstyle_client/src/domain/domain_exports.dart';
import '../../../domain/enums/clothing_category.dart';

class ClothingItemCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showFavoriteButton;

  const ClothingItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                            : getCategoryDisplayName(item.category),
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
            if (showFavoriteButton)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: item.isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String getCategoryDisplayName(ClothingCategory category) {
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
    }
  }
}

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showFavoriteButton;

  const OutfitCard({
    Key? key,
    required this.outfit,
    this.onTap,
    this.onLongPress,
    this.showFavoriteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                  if (showFavoriteButton)
                    Row(
                      children: [
                        Icon(
                          outfit.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: outfit.isFavorite ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${outfit.timesWorn} раз(а)',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
}

class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategoryChanged;

  const CategorySelector({
    Key? key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onCategoryChanged(index);
              }
            },
            selectedColor: Theme.of(context).primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          );
        },
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;
  final List<String> filterOptions;

  const FilterButton({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.filterOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (String result) {
        onFilterChanged(result);
      },
      itemBuilder: (BuildContext context) => filterOptions.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (currentFilter == option) const Icon(Icons.check, size: 18),
              const SizedBox(width: 8),
              Text(option),
            ],
          ),
        );
      }).toList(),
    );
  }
}
