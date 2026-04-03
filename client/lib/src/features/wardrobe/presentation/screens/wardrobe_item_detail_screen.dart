import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../domain/entities/wardrobe_item.dart';
import '../providers/wardrobe_provider.dart';

/// Экран деталей предмета гардероба
class WardrobeItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const WardrobeItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<WardrobeItemDetailScreen> createState() =>
      _WardrobeItemDetailScreenState();
}

class _WardrobeItemDetailScreenState
    extends ConsumerState<WardrobeItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final wardrobeState = ref.watch(wardrobeProvider);
    final item = wardrobeState.items.cast<WardrobeItem?>().firstWhere(
      (i) => i?.id == widget.itemId,
      orElse: () => null,
    );

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали предмета')),
        body: _buildNotFound(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали предмета'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed:
                () => context.push('/wardrobe/item/${widget.itemId}/edit'),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: _buildContent(item),
    );
  }

  Widget _buildContent(WardrobeItem item) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildItemImage(item),
        const SizedBox(height: 24),
        Text(
          item.name ?? 'Без названия',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (item.category != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getCategoryName(item.category!),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        const SizedBox(height: 24),
        _buildInfoSection(theme, item),
        const SizedBox(height: 24),
        _buildStatsSection(theme, item),
        const SizedBox(height: 24),
        _buildActions(item),
      ],
    );
  }

  Widget _buildItemImage(WardrobeItem item) {
    final imageUrl = item.imageUrl;

    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Нет изображения', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: 300,
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.error)),
            ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, WardrobeItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Бренд', item.brand),
          _buildInfoRow('Цвет', item.color),
          _buildInfoRow('Размер', item.size),
          _buildInfoRow('Стиль', item.style),
          _buildInfoRow('Материалы', item.materials?.join(', ')),
          _buildInfoRow('Пол', _getGenderName(item.gender)),
          _buildInfoRow('Крой', _getFitName(item.fit)),
          _buildInfoRow('Узор', _getPatternName(item.pattern)),
          _buildInfoRow('Сезон', _getSeasonName(item.season)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, WardrobeItem item) {
    final usage = item.usage ?? 0;
    final warmthLevel = item.warmthLevel ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Использовано',
            '$usage раз',
            Icons.repeat,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Теплота',
            '⋅' * warmthLevel + '∘' * (5 - warmthLevel),
            Icons.thermostat,
            theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildActions(WardrobeItem item) {
    final isFavorite = item.isFavorite ?? false;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(wardrobeProvider.notifier).toggleFavorite(widget.itemId);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            label: Text(isFavorite ? 'В избранном' : 'В избранное'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _showDeleteConfirmation(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Удалить предмет'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Предмет не найден',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Возможно, он был удалён',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Удаление предмета'),
            content: const Text(
              'Вы уверены, что хотите удалить этот предмет? Это действие нельзя отменить.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ref.read(wardrobeProvider.notifier).removeItem(widget.itemId);
                  Navigator.pop(context);
                  if (context.mounted) {
                    context.pop();
                  }
                },
                icon: const Icon(Icons.delete),
                label: const Text('Удалить'),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  String _getCategoryName(String category) {
    const categories = {
      'tshirt': 'Футболка',
      'shirt': 'Рубашка',
      'jeans': 'Джинсы',
      'pants': 'Брюки',
      'shorts': 'Шорты',
      'jacket': 'Куртка',
      'coat': 'Пальто',
      'sneakers': 'Кроссовки',
      'shoes': 'Туфли',
      'boots': 'Ботинки',
      'hat': 'Шапка',
      'cap': 'Кепка',
      'scarf': 'Шарф',
      'gloves': 'Перчатки',
      'bag': 'Сумка',
      'belt': 'Ремень',
    };
    return categories[category] ?? category;
  }

  String _getGenderName(String? gender) {
    const genders = {
      'male': 'Мужской',
      'female': 'Женский',
      'unisex': 'Унисекс',
    };
    return genders[gender] ?? 'Не указано';
  }

  String _getFitName(String? fit) {
    const fits = {
      'slim': 'Slim (узкий)',
      'regular': 'Regular (классический)',
      'loose': 'Loose (свободный)',
      'oversized': 'Oversized',
    };
    return fits[fit] ?? fit ?? 'Не указано';
  }

  String _getPatternName(String? pattern) {
    const patterns = {
      'solid': 'Однотонный',
      'striped': 'В полоску',
      'checked': 'В клетку',
      'printed': 'С принтом',
      'gradient': 'Градиент',
    };
    return patterns[pattern] ?? pattern ?? 'Не указано';
  }

  String _getSeasonName(String? season) {
    const seasons = {
      'all_season': 'Всесезонный',
      'spring': 'Весна',
      'summer': 'Лето',
      'autumn': 'Осень',
      'winter': 'Зима',
    };
    return seasons[season] ?? season ?? 'Не указано';
  }
}
