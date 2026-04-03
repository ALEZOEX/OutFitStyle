import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../recommendations/presentation/providers/recommendations_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/weather_provider.dart';
import 'package:outfitstyle_client/src/presentation/providers/user_location_provider.dart';
import 'package:outfitstyle_client/src/ui/widgets/weather_card.dart';
import 'package:outfitstyle_client/src/ui/widgets/empty_state.dart';
import 'package:outfitstyle_client/src/ui/containers/glass_container.dart';
import 'package:outfitstyle_client/src/ui/widgets/max_width_container.dart';
import 'package:outfitstyle_client/src/domain/entities/outfit_recommendation.dart';
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
    final recommendationsState = ref.watch(recommendationsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(weatherProvider);
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
                // Отступ сверху
                const SizedBox(height: AppSpacing.lg),

                // Погода
                _WeatherSection(
                  weatherAsync: weatherAsync,
                  userLocation: userLocation,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Образ дня
                _OutfitOfDaySection(recommendationsState: recommendationsState),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.radiusXxl,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
                  onPressed: () => context.go('/recommendations'),
                  child: const Text('Все'),
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

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.radiusXxl,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildOutfitCard(BuildContext context, OutfitRecommendation rec) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: AppRadius.radiusXl,
      child: InkWell(
        onTap: () {
          if (rec.id != null) context.push('/outfit/${rec.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.5,
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

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (rec.id != null) {
                      context.push('/outfit/${rec.id}');
                    }
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Смотреть образ'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusPill,
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

  Widget _buildEmptyCard(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      borderRadius: AppRadius.radiusXl,
      child: EmptyState(
        icon: Icons.checkroom_outlined,
        title: 'Нет рекомендаций',
        subtitle: 'Сгенерируйте персональный образ',
        actionLabel: 'Сгенерировать',
        onAction: () => context.push('/generator'),
      ),
    );
  }
}
