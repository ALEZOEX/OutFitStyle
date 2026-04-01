import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/outfit_recommendation.dart';
import '../../../ui/widgets/max_width_container.dart';
import '../../../theme/app_theme.dart';

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
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              outfit.title ?? 'Без названия',
              style: AppTypography.headlineSmall(context),
            ),
            if (outfit.description != null &&
                outfit.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                outfit.description!,
                style: AppTypography.bodyMedium(context),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),

            _buildWeatherInfo(context, outfit),
            const SizedBox(height: AppSpacing.xxl),

            _buildItemsList(context, outfit),
            const SizedBox(height: AppSpacing.xxl),

            if (outfit.createdAt != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Информация',
                      style: AppTypography.labelLarge(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.xxl),
            ],

            _buildActions(context, outfit),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(BuildContext context, OutfitRecommendation outfit) {
    final theme = Theme.of(context);
    final temperature = outfit.temperature;
    final weatherCondition = outfit.weatherCondition;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: AppRadius.radiusLg,
      ),
      child: Row(
        children: [
          Icon(
            _getWeatherIcon(weatherCondition),
            size: 48,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: AppSpacing.lg),
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
                style: AppTypography.headlineSmall(
                  context,
                ).copyWith(color: theme.colorScheme.onPrimaryContainer),
              ),
              if (weatherCondition != null) ...[
                const SizedBox(height: 4),
                Text(
                  _getWeatherName(weatherCondition),
                  style: AppTypography.bodyMedium(
                    context,
                  ).copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, OutfitRecommendation outfit) {
    final theme = Theme.of(context);
    final items = outfit.recommendedItems ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Предметы в образе', style: AppTypography.headlineSmall(context)),
        const SizedBox(height: AppSpacing.lg),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 48,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Нет предметов'),
                ],
              ),
            ),
          )
        else
          ...items.map((itemId) => _buildItemRow(context, itemId)),
      ],
    );
  }

  Widget _buildItemRow(BuildContext context, String itemId) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(
              Icons.checkroom,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Предмет $itemId',
              style: AppTypography.bodyMedium(
                context,
              ).copyWith(fontWeight: FontWeight.w500),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, OutfitRecommendation outfit) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _useAsTemplate(outfit),
            icon: const Icon(Icons.copy),
            label: const Text('Использовать как шаблон'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _reportOutfit(outfit),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Пожаловаться'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Образ сохранён')));
  }

  void _useAsTemplate(OutfitRecommendation outfit) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Открывается конструктор...')));
  }

  void _reportOutfit(OutfitRecommendation outfit) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Функция жалоб в разработке')));
  }

  IconData _getWeatherIcon(String? condition) {
    return switch (condition) {
      'clear' => Icons.wb_sunny,
      'cloudy' => Icons.cloud,
      'rain' => Icons.water_drop,
      'snow' => Icons.ac_unit,
      'thunderstorm' => Icons.thunderstorm,
      _ => Icons.wb_sunny,
    };
  }

  String _getWeatherName(String? condition) {
    return switch (condition) {
      'clear' => 'Ясно',
      'cloudy' => 'Облачно',
      'rain' => 'Дождь',
      'snow' => 'Снег',
      'thunderstorm' => 'Гроза',
      _ => condition ?? '—',
    };
  }
}
