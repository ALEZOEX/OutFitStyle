import 'dart:ui';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          padding: const EdgeInsets.only(bottom: 120),
          child: ResponsiveMaxWidthContainer(
            maxWidth: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero-заголовок как на Landing
                _buildHeroHeader(context, isDark),
                const SizedBox(height: AppSpacing.xxl),

                // Погода
                _WeatherSection(
                  weatherAsync: weatherAsync,
                  userLocation: userLocation,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Образ дня
                _OutfitOfDaySection(recommendationsState: recommendationsState),
                const SizedBox(height: AppSpacing.xxl),

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

  /// Landing-style hero header с градиентным текстом
  Widget _buildHeroHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxxl,
        AppSpacing.xxl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Градиентный badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              gradient: isDark ? AppGradients.cardDark : AppGradients.cardLight,
              borderRadius: AppRadius.radiusPill,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'AI-подбор одежды',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Заголовок
          Text(
            'Что надеть\nсегодня?',
            style: AppTypography.displayLarge(context).copyWith(height: 1.1),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Подзаголовок
          Text(
            'Персональные рекомендации на основе погоды и вашего стиля',
            style: AppTypography.bodyMedium(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Погода — glass card
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
        // Город
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                userLocation.cityName ?? 'Город не выбран',
                style: AppTypography.labelLarge(context),
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
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.radiusXxl,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadius.radiusXxl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: AppRadius.radiusXxl,
            border: Border.all(color: AppColors.grey200.withValues(alpha: 0.3)),
          ),
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Образ дня — glass card
// ══════════════════════════════════════════════════════════════

class _OutfitOfDaySection extends StatelessWidget {
  final RecommendationsState recommendationsState;

  const _OutfitOfDaySection({required this.recommendationsState});

  @override
  Widget build(BuildContext context) {
    final recommendations = recommendationsState.recommendations;
    final isLoading =
        recommendationsState.status == RecommendationsLoadStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Text('Образ дня', style: AppTypography.headlineSmall(context)),
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

    return ClipRRect(
      borderRadius: AppRadius.radiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.08),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.secondary.withValues(alpha: 0.06),
                    ],
            ),
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (rec.id != null) context.push('/outfit/${rec.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
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
                            gradient: AppGradients.primary,
                            borderRadius: AppRadius.radiusPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.thermostat,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${rec.temperature?.round() ?? 0}°C',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (rec.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      rec.description!,
                      style: AppTypography.bodyMedium(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Вещи в пузырях
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
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: AppRadius.radiusPill,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppColors.grey200.withValues(alpha: 0.5),
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

                  const SizedBox(height: AppSpacing.xl),

                  // Кнопка — gradient
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppGradients.heroButton,
                        borderRadius: AppRadius.radiusPill,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (rec.id != null) {
                              context.push('/outfit/${rec.id}');
                            }
                          },
                          borderRadius: AppRadius.radiusPill,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Смотреть образ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.radiusXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.grey200.withValues(alpha: 0.3)),
          ),
          child: EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Нет рекомендаций',
            subtitle:
                'Получите персональный образ на основе погоды и вашего гардероба',
            actionLabel: 'Сгенерировать',
            onAction: () => context.go('/generator'),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: AppRadius.radiusXl,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Превью гардероба — glass category cards
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
    final items = wardrobeState.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              Text('Гардероб', style: AppTypography.headlineSmall(context)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${items.length} ${_itemsWord(items.length)}',
                style: AppTypography.bodyMedium(context),
              ),
              const Spacer(),
              TextButton(onPressed: onTap, child: const Text('Открыть')),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

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
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.1,
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

    return ClipRRect(
      borderRadius: AppRadius.radiusLg,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                      AppSpacing.sm + AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: isDark ? 0.25 : 0.15),
                          color.withValues(alpha: isDark ? 0.15 : 0.08),
                        ],
                      ),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Icon(
                      WardrobeCategories.getIcon(category),
                      color: color,
                      size: 24,
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
                  Text('$count', style: AppTypography.bodySmall(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'top':
        return AppColors.info;
      case 'bottom':
        return AppColors.success;
      case 'shoes':
        return AppColors.warning;
      case 'outerwear':
        return const Color(0xFF6366F1);
      case 'accessories':
        return AppColors.primary;
      case 'headwear':
        return const Color(0xFF14B8A6);
      default:
        return AppColors.grey400;
    }
  }
}
