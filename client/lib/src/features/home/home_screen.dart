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

class _OutfitOfDaySection extends ConsumerWidget {
  final RecommendationsState recommendationsState;

  const _OutfitOfDaySection({required this.recommendationsState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          _buildOutfitCard(context, ref, recommendations.first),
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

  Widget _buildOutfitCard(BuildContext context, WidgetRef ref, OutfitRecommendation rec) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemCount = rec.recommendedItems?.length ?? 0;
    final createdAt = rec.createdAt;

    return GlassContainer(
      borderRadius: AppRadius.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок + температура
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatTitle(rec.title),
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
              style: AppTypography.bodyMedium(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Предметы одежды
          if (rec.recommendedItems?.isNotEmpty ?? false) ...[
            ...rec.recommendedItems!.take(8).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      _getItemIcon(item),
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Информация
          if (createdAt != null || itemCount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (createdAt != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _formatDate(createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  if (itemCount > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.checkroom,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '$itemCount предметов',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Кнопка обновить
          InkWell(
            onTap: () {
              ref.read(recommendationsProvider.notifier).refresh();
            },
            borderRadius: AppRadius.radiusPill,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                ),
                borderRadius: AppRadius.radiusPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Обновить',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(String item) {
    final lower = item.toLowerCase();
    if (lower.contains('футболк') || lower.contains('рубашк')) {
      return Icons.checkroom;
    }
    if (lower.contains('брюк') || lower.contains('джинс')) {
      return Icons.outbond;
    }
    if (lower.contains('куртк') || lower.contains('пальто')) {
      return Icons.umbrella_outlined;
    }
    if (lower.contains('обув') || lower.contains('кроссовк')) {
      return Icons.directions_walk;
    }
    if (lower.contains('шапк') || lower.contains('шляп')) {
      return Icons.backpack;
    }
    return Icons.checkroom;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Сегодня';
    if (diff.inDays == 1) return 'Вчера';
    if (diff.inDays < 7) return '${diff.inDays} дн. назад';
    return '${date.day}.${date.month}.${date.year}';
  }

  String _formatTitle(String? title) {
    if (title == null || title.isEmpty) return 'Ваш образ';

    // Если title похо на номер версии (1.1.1, 2.0.1 и т.д.) — заменяем
    final versionPattern = RegExp(r'^\d+\.\d+\.\d+$');
    if (versionPattern.hasMatch(title)) {
      return 'Ваш образ';
    }

    return title;
  }

  Widget _buildEmptyCard(BuildContext context) {
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
