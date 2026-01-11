import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/local/app_database.dart';
import 'outfit_collage_interactive.dart';


class OutfitOfDayCard extends StatelessWidget {
  final RecommendationRow recommendation;
  final Map<String, dynamic> outfitData;
  final VoidCallback onLike;

  const OutfitOfDayCard({
    super.key,
    required this.recommendation,
    required this.outfitData,
    required this.onLike,
  });

  List<Map<String, dynamic>> _outfitLines() {
    final raw = outfitData['outfit'];
    if (raw is List) {
      return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final lines = _outfitLines();

    return Hero(
      tag: 'outfit_${recommendation.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/outfit/${recommendation.id}'),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Образ дня',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: onLike,
                          icon: Icon(
                            recommendation.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: recommendation.isFavorite ? Colors.pinkAccent : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Интерактивный коллаж
                    Expanded(
                      child: OutfitCollageInteractive(lines: lines),
                    ),

                    const SizedBox(height: 12),

                    // Мини-CTA: "Открыть", "Сгенерировать альтернативу"
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              context.push('/outfit/${recommendation.id}');
                            },
                            child: const Text('Открыть'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filledTonal(
                          onPressed: () {
                            // позже: генерация альтернативы (не блокируя UI)
                          },
                          icon: const Icon(Icons.shuffle_rounded),
                          tooltip: 'Альтернатива',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

