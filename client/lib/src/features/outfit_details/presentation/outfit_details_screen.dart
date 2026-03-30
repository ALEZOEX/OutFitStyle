import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/outfit_recommendation.dart';
import '../../../ui/widgets/max_width_container.dart';

/// Экран деталей образа
class OutfitDetailsScreen extends ConsumerStatefulWidget {
  final String outfitId;

  const OutfitDetailsScreen({super.key, required this.outfitId});

  @override
  ConsumerState<OutfitDetailsScreen> createState() =>
      _OutfitDetailsScreenState();
}

class _OutfitDetailsScreenState extends ConsumerState<OutfitDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Для демонстрации - моковые данные
    // В реальности нужно загрузить outfit по ID через провайдер
    final outfit = OutfitRecommendation(
      id: widget.outfitId,
      title: 'Повседневный образ',
      description: 'Удобный и стильный образ для прогулки',
      temperature: 18.0,
      weatherCondition: 'cloudy',
      createdAt: DateTime.now(),
      recommendedItems: ['item_1', 'item_2', 'item_3'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали образа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareOutfit(outfit),
            tooltip: 'Поделиться',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _saveOutfit(outfit),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: ResponsiveMaxWidthContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Заголовок
            Text(
              outfit.title ?? 'Без названия',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (outfit.description != null &&
                outfit.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                outfit.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Погода
            _buildWeatherInfo(theme, outfit),
            const SizedBox(height: 24),

            // Предметы
            _buildItemsList(theme, outfit),
            const SizedBox(height: 24),

            // Дата создания
            if (outfit.createdAt != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Создан',
                      '${outfit.createdAt!.day}.${outfit.createdAt!.month}.${outfit.createdAt!.year}',
                    ),
                    _buildInfoRow(
                      'Предметов',
                      '${outfit.recommendedItems?.length ?? 0}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Действия
            _buildActions(outfit),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(
    ThemeData theme,
    OutfitRecommendation outfit,
  ) {
    final temperature = outfit.temperature;
    final weatherCondition = outfit.weatherCondition;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(weatherCondition),
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Погода',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                temperature != null ? '${temperature.round()}°C' : '—',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (weatherCondition != null) ...[
                const SizedBox(height: 4),
                Text(
                  _getWeatherName(weatherCondition),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    ThemeData theme,
    OutfitRecommendation outfit,
  ) {
    final items = outfit.recommendedItems ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Предметы в образе',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.checkroom_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Нет предметов'),
                ],
              ),
            ),
          )
        else
          ...items.map((itemId) => _buildItemRow(theme, itemId)),
      ],
    );
  }

  Widget _buildItemRow(ThemeData theme, String itemId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.checkroom,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Предмет $itemId',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: () => context.push('/wardrobe/item/$itemId'),
            tooltip: 'Открыть',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(OutfitRecommendation outfit) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _useAsTemplate(outfit),
            icon: const Icon(Icons.copy),
            label: const Text('Использовать как шаблон'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _reportOutfit(outfit),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Пожаловаться'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  void _shareOutfit(OutfitRecommendation outfit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция шеринга в разработке')),
    );
  }

  void _saveOutfit(OutfitRecommendation outfit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Образ сохранён')),
    );
  }

  void _useAsTemplate(OutfitRecommendation outfit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Открывается конструктор...')),
    );
  }

  void _reportOutfit(OutfitRecommendation outfit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Функция жалоб в разработке')),
    );
  }

  IconData _getWeatherIcon(String? condition) {
    switch (condition) {
      case 'clear':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.thunderstorm;
      default:
        return Icons.wb_sunny;
    }
  }

  String _getWeatherName(String? condition) {
    switch (condition) {
      case 'clear':
        return 'Ясно';
      case 'cloudy':
        return 'Облачно';
      case 'rain':
        return 'Дождь';
      case 'snow':
        return 'Снег';
      case 'thunderstorm':
        return 'Гроза';
      default:
        return condition ?? '—';
    }
  }
}
