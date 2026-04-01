import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../wardrobe/presentation/providers/wardrobe_provider.dart';
import '../recommendations/presentation/providers/recommendations_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/weather_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/user_location_provider.dart';
import 'package:outfitstyle_client/src/ui/widgets/weather_card.dart';
import 'package:outfitstyle_client/src/ui/widgets/empty_state.dart';
import 'package:outfitstyle_client/src/ui/widgets/max_width_container.dart';
import 'package:outfitstyle_client/src/domain/entities/outfit_recommendation.dart';
import 'package:outfitstyle_client/src/domain/entities/wardrobe_item.dart';
import 'package:outfitstyle_client/src/theme/app_theme.dart';

/// Упрощённый главный экран-дашборд.
///
/// Структура (сверху вниз):
/// 1. Погода — WeatherCard
/// 2. Образ дня — первая рекомендация или пустое состояние
/// 3. Гардероб — превью по категориям с количеством
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationProvider);
    final weatherAsync = ref.watch(
      weatherProvider((
        lat: userLocation.latitude,
        lon: userLocation.longitude,
      )),
    );
    final wardrobeState = ref.watch(wardrobeProvider);
    final recommendationsState = ref.watch(recommendationsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weatherProvider);
        ref.invalidate(wardrobeProvider);
        ref.invalidate(recommendationsProvider);
      },
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: ResponsiveMaxWidthContainer(
            maxWidth: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Погода
                _WeatherSection(
                  weatherAsync: weatherAsync,
                  userLocation: userLocation,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Образ дня
                _OutfitOfDaySection(recommendationsState: recommendationsState),
                const SizedBox(height: AppSpacing.xl),

                // Гардероб
                _WardrobePreviewSection(
                  wardrobeState: wardrobeState,
                  onTap: () => _navigateToTab(context, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    context.go('/', extra: index);
  }
}

// ══════════════════════════════════════════════════════════════
// Погода
// ══════════════════════════════════════════════════════════════

class _WeatherSection extends ConsumerWidget {
  final AsyncValue<dynamic> weatherAsync;
  final UserLocation userLocation;

  const _WeatherSection({
    required this.weatherAsync,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Город + кнопка смены
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                userLocation.cityName ?? 'Город не выбран',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showCitySelector(context, ref),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Изменить', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Карточка погоды
        weatherAsync.when(
          data: (weather) => WeatherCard(
            weatherData: weather,
            forecast: const [],
            onTap: () => ref.invalidate(weatherProvider),
            onRefresh: () => ref.invalidate(weatherProvider),
          ),
          loading: () => _buildLoadingCard(context),
          error: (_, __) => _buildErrorCard(context, ref),
        ),
      ],
    );
  }

  void _showCitySelector(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выбор города'),
        content: const Text(
          'Используйте кнопку местоположения в верхней панели',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXxl),
      child: const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXxl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Icon(Icons.cloud_off, size: 40, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            const Text('Не удалось загрузить погоду'),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(weatherProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Образ дня
// ══════════════════════════════════════════════════════════════

class _OutfitOfDaySection extends StatelessWidget {
  final RecommendationsState recommendationsState;

  const _OutfitOfDaySection({required this.recommendationsState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendations = recommendationsState.recommendations;
    final isLoading =
        recommendationsState.status == RecommendationsLoadStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Text(
                'Образ дня',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (recommendations.isNotEmpty)
                TextButton(
                  onPressed: () => context.go('/', extra: 2),
                  child: const Text('Все рекомендации'),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Контент
        if (isLoading)
          _buildLoadingCard(context)
        else if (recommendations.isEmpty)
          _buildEmptyCard(context)
        else
          _buildOutfitCard(context, recommendations.first),
      ],
    );
  }

  Widget _buildOutfitCard(BuildContext context, OutfitRecommendation rec) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      child: InkWell(
        onTap: () {
          if (rec.id != null) {
            context.push('/outfit/${rec.id}');
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark ? AppGradients.cardDark : AppGradients.cardLight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок + температура
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rec.title ?? 'Ваш образ',
                        style: AppTypography.headlineSmall(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (rec.temperature != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: AppRadius.radiusPill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.thermostat,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${rec.temperature?.round() ?? 0}°C',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Описание
                if (rec.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    rec.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Список вещей
                if (rec.recommendedItems?.isNotEmpty ?? false)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: rec.recommendedItems!.take(6).map((item) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Кнопка
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (rec.id != null) {
                        context.push('/outfit/${rec.id}');
                      }
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Подробнее'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return EmptyState(
      icon: Icons.checkroom_outlined,
      title: 'Нет рекомендаций',
      subtitle:
          'Получите персональный образ на основе погоды и вашего гардероба',
      actionLabel: 'Сгенерировать',
      onAction: () => context.go('/generator'),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
      child: const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Превью гардероба
// ══════════════════════════════════════════════════════════════

class _WardrobePreviewSection extends StatelessWidget {
  final WardrobeState wardrobeState;
  final VoidCallback onTap;

  const _WardrobePreviewSection({
    required this.wardrobeState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = wardrobeState.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Text(
                'Гардероб',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${items.length} ${_itemsWord(items.length)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(onPressed: onTap, child: const Text('Открыть')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Карточки категорий
        if (items.isEmpty)
          _buildEmptyWardrobe(context)
        else
          _buildCategoryGrid(context, items),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<WardrobeItem> items) {
    final counts = <String, int>{};
    for (final item in items) {
      final cat = item.category ?? 'other';
      counts[cat] = (counts[cat] ?? 0) + 1;
    }

    final categories = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final entry = categories[index];
        return _CategoryCard(
          category: entry.key,
          count: entry.value,
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildEmptyWardrobe(BuildContext context) {
    return EmptyState(
      icon: Icons.checkroom_outlined,
      title: 'Гардероб пуст',
      subtitle: 'Добавьте вещи, чтобы получать рекомендации',
      actionLabel: 'Добавить',
      onAction: onTap,
    );
  }

  String _itemsWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'вещь';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'вещи';
    }
    return 'вещей';
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _getCategoryColor(category);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  WardrobeCategories.getIcon(category),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                WardrobeCategories.getNameRu(category),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'top':
        return Colors.blue;
      case 'bottom':
        return Colors.green;
      case 'shoes':
        return Colors.orange;
      case 'outerwear':
        return Colors.indigo;
      case 'accessories':
        return AppColors.primary;
      case 'headwear':
        return Colors.teal;
      default:
        return AppColors.grey400;
    }
  }
}
