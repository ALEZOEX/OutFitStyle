import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/skeleton.dart';
import '../../../ui/atoms/like_burst.dart';
import 'recommendations_controller.dart';

class RecommendationCard extends ConsumerWidget {
  final RecommendationRow recommendation;
  final VoidCallback? onTap;
  const RecommendationCard(
      {super.key, required this.recommendation, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(recommendationsControllerProvider.notifier);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Рекомендация',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      Haptics.selection();
                      await controller.toggleFavorite(recommendation);
                    },
                    icon: Icon(
                      recommendation.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          recommendation.isFavorite ? Colors.pinkAccent : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _WeatherPreview(weatherJson: recommendation.weatherDataJson),
              const SizedBox(height: 12),
              _OutfitPreview(outfitJson: recommendation.outfitDataJson),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherPreview extends StatelessWidget {
  final String weatherJson;
  const _WeatherPreview({required this.weatherJson});

  @override
  Widget build(BuildContext context) {
    try {
      final weather = (jsonDecode(weatherJson) as Map).cast<String, dynamic>();
      final temp = (weather['temp'] ?? weather['temperature'] ?? '').toString();
      final condition = (weather['condition'] ??
              weather['description'] ??
              weather['weather'] ??
              '')
          .toString();

      return Row(
        children: [
          const Icon(Icons.wb_sunny_rounded),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              condition.isEmpty ? 'Погода' : condition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            temp.isEmpty ? '—' : '$temp°',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      );
    } catch (e) {
      return const Text('Данные о погоде недоступны');
    }
  }
}

class _OutfitPreview extends StatelessWidget {
  final String outfitJson;
  const _OutfitPreview({required this.outfitJson});

  @override
  Widget build(BuildContext context) {
    try {
      final outfit = (jsonDecode(outfitJson) as Map).cast<String, dynamic>();
      final lines = (outfit['outfit'] is List)
          ? (outfit['outfit'] as List)
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : <Map<String, dynamic>>[];

      if (lines.isEmpty) {
        return const Text('Нет данных об образе');
      }

      // Показываем первые 3 элемента
      final show = lines.take(3).toList();

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: show.map((line) {
          final icon = (line['icon_emoji'] ?? '👕').toString();
          final name = (line['name'] ?? 'Вещь').toString();
          final category = (line['category'] ?? 'Категория').toString();

          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 2),
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
      );
    } catch (e) {
      return const Text('Данные об образе недоступны');
    }
  }
}
