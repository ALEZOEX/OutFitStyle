import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di.dart';
import '../../../domain/entities/recommendation_entity.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import '../../../ui/atoms/skeleton.dart';
import 'recommendations_controller.dart';

final recommendationByIdProvider =
    StreamProvider.autoDispose.family<RecommendationRow?, String>((ref, id) {
  final repo = ref.watch(recommendationsRepositoryProvider);
  return repo.watchById(id);
});

class RecommendationDetailScreen extends ConsumerWidget {
  final String recommendationId;
  const RecommendationDetailScreen({super.key, required this.recommendationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationAsync =
        ref.watch(recommendationByIdProvider(recommendationId));
    final controller = ref.read(recommendationsControllerProvider.notifier);

    return recommendationAsync.when(
      loading: () => Scaffold(
        appBar: OutfitAppBar(title: const Text('Рекомендация')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: OutfitAppBar(title: const Text('Рекомендация')),
        body: Center(child: Text('Ошибка: $e')),
      ),
      data: (recommendation) {
        if (recommendation == null) {
          return const Scaffold(
            body: Center(child: Text('Рекомендация не найдена')),
          );
        }

        return Scaffold(
          appBar: OutfitAppBar(
            title: 'Детали рекомендации',
            actions: [
              IconButton(
                onPressed: () async {
                  Haptics.selection();
                  await controller.toggleFavorite(recommendation);
                },
                icon: Icon(
                  recommendation.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: recommendation.isFavorite ? Colors.pinkAccent : null,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Погода
              _WeatherCard(weatherDataJson: recommendation.weatherDataJson),
              const SizedBox(height: 16),

              // Состав образа
              _OutfitComposition(outfitDataJson: recommendation.outfitDataJson),

              const SizedBox(height: 16),

              // Дополнительная информация
              _AdditionalInfo(recommendation: recommendation),
            ],
          ),
        );
      },
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final String weatherDataJson;
  const _WeatherCard({required this.weatherDataJson});

  @override
  Widget build(BuildContext context) {
    try {
      final weather =
          (jsonDecode(weatherDataJson) as Map).cast<String, dynamic>();
      final temp = (weather['temp'] ?? weather['temperature'] ?? '').toString();
      final condition = (weather['condition'] ??
              weather['description'] ??
              weather['weather'] ??
              '')
          .toString();

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Погода',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition.isEmpty ? 'Данные недоступны' : condition,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                temp.isEmpty ? '—' : '$temp°',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка при отображении погоды: $e'),
        ),
      );
    }
  }
}

class _OutfitComposition extends StatelessWidget {
  final String outfitDataJson;
  const _OutfitComposition({required this.outfitDataJson});

  @override
  Widget build(BuildContext context) {
    try {
      final outfit =
          (jsonDecode(outfitDataJson) as Map).cast<String, dynamic>();
      final lines = (outfit['outfit'] is List)
          ? (outfit['outfit'] as List)
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : <Map<String, dynamic>>[];

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Состав образа',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: lines.map((item) {
                  final icon = (item['icon_emoji'] ?? '👕').toString();
                  final name = (item['name'] ?? 'Вещь').toString();
                  final category = (item['category'] ?? 'Категория').toString();

                  return Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка при отображении состава образа: $e'),
        ),
      );
    }
  }
}

class _AdditionalInfo extends StatelessWidget {
  final RecommendationRow recommendation;
  const _AdditionalInfo({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительная информация',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Дата создания',
              value: recommendation.createdAt.toString(),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Обновлено',
              value: recommendation.updatedAt.toString(),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Избранное',
              value: recommendation.isFavorite ? 'Да' : 'Нет',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.65),
                ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
