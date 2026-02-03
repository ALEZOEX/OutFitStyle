import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../domain/entities/recommendation_entity.dart';
import '../../../ui/atoms/haptics.dart';
import 'home_controller.dart';

class WeatherCard extends ConsumerWidget {
  final Map<String, dynamic> weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temp = (weather['temp'] ?? weather['temperature'] ?? '').toString();
    final condition = (weather['condition'] ??
            weather['description'] ??
            weather['weather'] ??
            '')
        .toString();
    final location = (weather['location'] ?? weather['city'] ?? '').toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
                    location.isEmpty ? 'Ваше местоположение' : location,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    condition.isEmpty ? 'Погода' : condition,
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
  }
}

class OutfitOfDayCard extends ConsumerWidget {
  final RecommendationRow recommendation;
  final List<Map<String, dynamic>> outfitData;
  final VoidCallback onLike;
  const OutfitOfDayCard({
    super.key,
    required this.recommendation,
    required this.outfitData,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Фоновое изображение (если есть)
          if (recommendation.imageUrl != null)
            Positioned.fill(
              child: Image.network(
                recommendation.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),

          // Контент поверх
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Образ дня',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                    IconButton(
                      onPressed: onLike,
                      icon: Icon(
                        recommendation.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: recommendation.isFavorite
                            ? Colors.pinkAccent
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _OutfitCollage(lines: outfitData),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Haptics.selection();
                    // Navigate to recommendation detail
                    // context.push('/home/recommendations/${recommendation.id}');
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Подробнее'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutfitCollage extends StatelessWidget {
  final List<Map<String, dynamic>> lines;
  const _OutfitCollage({required this.lines});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Center(
        child: Text(
          'Нет данных об образе',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.white),
        ),
      );
    }

    // Показываем первые 4 элемента
    final show = lines.take(4).toList();

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.9,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: show.map((item) {
        final icon = (item['icon_emoji'] ?? '👕').toString();
        final name = (item['name'] ?? 'Вещь').toString();
        final category = (item['category'] ?? 'Категория').toString();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon,
                  style: const TextStyle(fontSize: 36, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
