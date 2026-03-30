import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/providers/weather_provider.dart';
import '../presentation/providers/user_location_provider.dart';
import '../features/recommendations/presentation/providers/recommendations_provider.dart';
import '../ui/widgets/weather_card.dart';
import '../ui/widgets/recommendation_card.dart';

/// Экран «Образ по погоде» — показывает текущую погоду и рекомендации одежды
class WeatherOutfitScreen extends ConsumerWidget {
  const WeatherOutfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationProvider);
    final weatherAsync = ref.watch(
      weatherProvider((
        lat: userLocation.latitude,
        lon: userLocation.longitude,
      )),
    );
    final recState = ref.watch(recommendationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Образ по погоде'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weatherProvider);
          await ref.read(recommendationsProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Карточка погоды
              WeatherCard(
                weatherAsync: weatherAsync,
                userLocation: userLocation,
              ),
              const SizedBox(height: 24),

              // Рекомендации
              Text(
                'Рекомендации',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (recState.status == RecommendationsLoadStatus.loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (recState.status == RecommendationsLoadStatus.error)
                _ErrorBlock(
                  error: recState.error ?? 'Ошибка загрузки',
                  onRetry:
                      () =>
                          ref.read(recommendationsProvider.notifier).refresh(),
                )
              else if (recState.recommendations.isEmpty)
                _EmptyState(
                  onGenerate:
                      () => _generateFromWeather(context, ref, weatherAsync),
                )
              else
                ...recState.recommendations.map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecommendationCard(recommendation: rec),
                  ),
                ),

              const SizedBox(height: 16),

              // Кнопка генерации нового образа
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed:
                      recState.isGenerating
                          ? null
                          : () =>
                              _generateFromWeather(context, ref, weatherAsync),
                  icon:
                      recState.isGenerating
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.auto_awesome),
                  label: Text(
                    recState.isGenerating
                        ? 'Генерация...'
                        : 'Сгенерировать образ',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateFromWeather(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> weatherAsync,
  ) async {
    double? temp;
    String? condition;

    weatherAsync.whenData((w) {
      temp = w.temperature;
      condition = w.weatherMain;
    });

    final result = await ref
        .read(recommendationsProvider.notifier)
        .generateRecommendation(temperature: temp, weatherCondition: condition);

    if (result == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сгенерировать образ')),
      );
    }
  }
}

class _ErrorBlock extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.onErrorContainer,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('Нет рекомендаций', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Нажмите кнопку ниже, чтобы получить образ по текущей погоде',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
