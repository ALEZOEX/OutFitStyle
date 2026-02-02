import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di.dart';
import '../../../ui/atoms/haptics.dart';
import '../../../ui/atoms/outfit_app_bar.dart';
import 'package:outfitstyle_client/models/wardrobe_models.dart';
import '../../../data/local/app_database.dart';

final _wardrobeByCategoryProvider = FutureProvider<Map<String, List<WardrobeEntry>>>((ref) async {
  final repo = ref.watch(wardrobeRepositoryProvider);
  final items = await repo.watchWardrobe(includeArchived: false).first;
  final byCat = <String, List<WardrobeEntry>>{};
  
  for (final item in items) {
    byCat.putIfAbsent(item.category, () => []).add(item);
  }
  
  return byCat;
});

class WardrobeRecommendationIntegration extends ConsumerWidget {
  final String recommendationId;
  final Map<String, dynamic> outfitData;
  final Map<String, dynamic> weatherData;
  
  const WardrobeRecommendationIntegration({
    super.key,
    required this.recommendationId,
    required this.outfitData,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wardrobeByCategory = ref.watch(_wardrobeByCategoryProvider);
    final controller = ref.read(recommendationRepositoryProvider);

    return Scaffold(
      appBar: OutfitAppBar(
        title: 'Интеграция с гардеробом',
        actions: [
          IconButton(
            onPressed: () async {
              Haptics.selection();
              // Сохранить рекомендацию как избранную
              final row = RecommendationRow(
                id: recommendationId,
                createdAt: DateTime.now(),
                isFavorite: true,
                outfitDataJson: jsonEncode(outfitData),
                weatherDataJson: jsonEncode(weatherData),
                updatedAt: DateTime.now(),
                dirty: false,
                lastSyncedAt: DateTime.now(),
              );
              
              await controller.toggleFavorite(row);
            },
            icon: const Icon(Icons.bookmark_add_rounded),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: wardrobeByCategory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (byCategory) {
          final lines = (outfitData['outfit'] is List)
              ? (outfitData['outfit'] as List)
                  .whereType<Map>()
                  .map((e) => e.cast<String, dynamic>())
                  .toList()
              : <Map<String, dynamic>>[];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Погода
              _WeatherCard(weatherData: weatherData),
              const SizedBox(height: 16),

              // Состав рекомендации
              _RecommendationComposition(
                lines: lines,
                wardrobeByCategory: byCategory,
              ),
              const SizedBox(height: 16),

              // Возможность заменить вещи из рекомендации на вещи из гардероба
              _WardrobeIntegrationSection(
                lines: lines,
                wardrobeByCategory: byCategory,
                onSave: (finalLines) async {
                  // Сохранить новый состав образа
                  final finalOutfit = {
                    'outfit': finalLines,
                  };

                  final newId = await controller.saveLocalOutfit(
                    outfitData: finalOutfit,
                    weatherData: weatherData,
                    favorite: true,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Образ сохранен с ID: $newId')),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;
  const _WeatherCard({required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final temp = (weatherData['temp'] ?? weatherData['temperature'] ?? '').toString();
    final condition = (weatherData['condition'] ?? weatherData['description'] ?? weatherData['weather'] ?? '').toString();

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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationComposition extends StatelessWidget {
  final List<Map<String, dynamic>> lines;
  final Map<String, List<WardrobeEntry>> wardrobeByCategory;
  
  const _RecommendationComposition({
    required this.lines,
    required this.wardrobeByCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Рекомендованный состав',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...lines.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final category = (item['category'] ?? '').toString();
              final alternatives = wardrobeByCategory[category] ?? [];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          (item['icon_emoji'] ?? '👕').toString(),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (item['name'] ?? 'Вещь').toString(),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                category,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (alternatives.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Альтернативы из вашего гардероба:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: alternatives.take(3).map((wardrobeItem) {
                          return ChoiceChip(
                            label: Text(wardrobeItem.name),
                            selected: false,
                            onSelected: (selected) {
                              // Здесь можно добавить логику выбора альтернативы
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WardrobeIntegrationSection extends StatefulWidget {
  final List<Map<String, dynamic>> lines;
  final Map<String, List<WardrobeEntry>> wardrobeByCategory;
  final Function(List<Map<String, dynamic>>) onSave;

  const _WardrobeIntegrationSection({
    required this.lines,
    required this.wardrobeByCategory,
    required this.onSave,
  });

  @override
  State<_WardrobeIntegrationSection> createState() => _WardrobeIntegrationSectionState();
}

class _WardrobeIntegrationSectionState extends State<_WardrobeIntegrationSection> {
  final Map<String, WardrobeEntry?> _selections = {};

  @override
  void initState() {
    super.initState();
    
    // Инициализируем выбор по умолчанию (оригинальные вещи)
    for (final line in widget.lines) {
      final category = (line['category'] ?? '').toString();
      _selections[category] = null; // null означает оригинальную вещь
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Заменить на вещи из гардероба',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            ...widget.lines.map((line) {
              final category = (line['category'] ?? '').toString();
              final alternatives = widget.wardrobeByCategory[category] ?? [];
              final selected = _selections[category];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<WardrobeEntry?>(
                            segments: [
                              ButtonSegment(
                                value: null,
                                label: Text('Оригинал: ${(line['name'] ?? 'Вещь').toString()}'),
                              ),
                              ...alternatives.map(
                                (item) => ButtonSegment(
                                  value: item,
                                  label: Text(item.name),
                                ),
                              ),
                            ],
                            selected: {selected},
                            onSelectionChanged: (newSelection) {
                              setState(() {
                                _selections[category] = newSelection.single;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Haptics.selection();
                
                // Создаем финальный состав на основе выбора
                final finalLines = <Map<String, dynamic>>[];
                
                for (final line in widget.lines) {
                  final category = (line['category'] ?? '').toString();
                  final selected = _selections[category];
                  
                  if (selected != null) {
                    // Используем выбранную вещь из гардероба
                    finalLines.add({
                      'id': selected.id,
                      'name': selected.name,
                      'category': selected.category,
                      'subcategory': selected.subcategory,
                      'icon_emoji': selected.iconEmoji,
                      'source': 'wardrobe',
                      'is_owned': true,
                    });
                  } else {
                    // Используем оригинальную рекомендацию
                    finalLines.add(line);
                  }
                }
                
                widget.onSave(finalLines);
              },
              icon: const Icon(Icons.save_rounded),
              label: const Text('Сохранить как новый образ'),
            ),
          ],
        ),
      ),
    );
  }
}