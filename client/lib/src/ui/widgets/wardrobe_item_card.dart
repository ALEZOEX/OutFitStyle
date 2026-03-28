import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/wardrobe_item.dart';

/// Карточка элемента гардероба
class WardrobeItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showDetails;

  const WardrobeItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение
              Stack(
                children: [
                  AspectRatio(aspectRatio: 1, child: _buildImage(context)),
                  // Кнопка избранного
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: onFavorite,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.black.withOpacity(0.6)
                                    : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            item.isFavorite == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color:
                                item.isFavorite == true
                                    ? Colors.red
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  // Бейдж категории
                  if (item.category != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getCategoryEmoji(item.category!) +
                              ' ' +
                              _getCategoryName(item.category!),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Информация
              if (showDetails)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name ?? 'Без названия',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (item.brand != null && item.brand!.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    item.brand!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              if (item.color != null &&
                                  item.color!.isNotEmpty) ...[
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getColorFromString(item.color!),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.color!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Количество носок и последняя носка
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (item.wearCount != null) ...[
                                Icon(
                                  Icons.refresh,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.wearCount} нос.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                              if (item.wearCount != null &&
                                  item.lastWornAt != null) ...[
                                const SizedBox(width: 12),
                              ],
                              if (item.lastWornAt != null) ...[
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatLastWorn(item.lastWornAt!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.checkroom_outlined,
          size: 48,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    return switch (category.toLowerCase()) {
      'верх' || 'top' => '👕',
      'низ' || 'bottom' => '👖',
      'обувь' || 'shoes' => '👟',
      'головной убор' || 'headwear' => '🧢',
      'аксессуар' || 'accessory' => '🧣',
      'верхняя одежда' || 'outerwear' => '🧥',
      _ => '👔',
    };
  }

  String _getCategoryName(String category) {
    return switch (category.toLowerCase()) {
      'верх' || 'top' => 'Верх',
      'низ' || 'bottom' => 'Низ',
      'обувь' || 'shoes' => 'Обувь',
      'головной убор' || 'headwear' => 'Голова',
      'аксессуар' || 'accessory' => 'Аксессуар',
      'верхняя одежда' || 'outerwear' => 'Верхняя',
      _ => category,
    };
  }

  String _formatLastWorn(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} нед. назад';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} мес. назад';
    } else {
      return '${(difference.inDays / 365).floor()} г. назад';
    }
  }

  Color _getColorFromString(String colorName) {
    final colorMap = {
      'черный': Colors.black,
      'белый': Colors.white,
      'красный': Colors.red,
      'синий': Colors.blue,
      'зеленый': Colors.green,
      'желтый': Colors.yellow,
      'оранжевый': Colors.orange,
      'фиолетовый': Colors.purple,
      'розовый': Colors.pink,
      'коричневый': Colors.brown,
      'серый': Colors.grey,
      'бежевый': const Color(0xFFD4C5B0),
    };

    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }
}

/// Карточка категории для фильтрации
class CategoryFilterChip extends StatelessWidget {
  final String category;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.category,
    required this.count,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getCategoryEmoji(category)),
          const SizedBox(width: 4),
          Text(
            _getCategoryName(category),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? theme.colorScheme.onPrimary.withOpacity(0.3)
                      : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
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
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    return switch (category.toLowerCase()) {
      'все' => '📋',
      'верх' || 'top' => '👕',
      'низ' || 'bottom' => '👖',
      'обувь' || 'shoes' => '👟',
      'головной убор' || 'headwear' => '🧢',
      'аксессуар' || 'accessory' => '🧣',
      'верхняя одежда' || 'outerwear' => '🧥',
      _ => '👔',
    };
  }

  String _getCategoryName(String category) {
    return switch (category.toLowerCase()) {
      'все' => 'Все',
      'верх' || 'top' => 'Верх',
      'низ' || 'bottom' => 'Низ',
      'обувь' || 'shoes' => 'Обувь',
      'головной убор' || 'headwear' => 'Голова',
      'аксессуар' || 'accessory' => 'Аксессуар',
      'верхняя одежда' || 'outerwear' => 'Верхняя',
      _ => category,
    };
  }
}
